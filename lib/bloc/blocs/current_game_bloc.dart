import 'dart:async';
import 'package:meta/meta.dart';

import 'package:bloc/bloc.dart';
import 'package:supercharged/supercharged.dart';

import '../../constants/enums.dart';
import '../../models/app_models/game.dart';
import '../../models/app_models/player.dart';
import '../../models/app_models/rules.dart';
import '../../services/dialog_information_service.dart';
import '../../services/information_storage.dart';
import '../../services/log_service.dart';
import '../../services/network_service/network_service_interface.dart';
import '../events/current_game_events.dart';
import '../states/current_game_states.dart';

/// {@template currentgamebloc}
///
/// {@endtemplate}
class CurrentGameBloc extends Bloc<CurrentGameEvent, CurrentGameState> {
  final INetworkService networkService;
  StreamSubscription gameSub;
  String get gameId => InformationStorage.instance.gameId;
  String get gameLink => InformationStorage.instance.gameLink;
  String get _playerId => InformationStorage.instance.playerId;
  Player _self;

  Game get _currentGame => networkService.currentGame;
  Game get _previousGame => networkService.previousGame;

  /// {@macro currentgamebloc}
  CurrentGameBloc(this.networkService) : super(CurrentGameEmpty());

  @override
  Stream<CurrentGameState> mapEventToState(CurrentGameEvent event) async* {
    if (event is StartGame) {
      yield* _mapStartGameToState(event);
    } else if (event is OpenGameWaitingLobby) {
      yield* _mapOpenGameWaitingLobbyToState(event);
    } else if (event is LeaveGame) {
      yield* _mapLeaveGameToState(event);
    } else if (event is EndGame) {
      yield* _mapEndGameToState(event);
    } else if (event is UpdateCurrentGame) {
      yield* _mapUpdateCurrentGameToState(event);
    } else if (event is PlayCard) {
      yield* _mapPlayCardToState(event);
    } else if (event is DrawCard) {
      yield* _mapDrawCardToState(event);
    } else if (event is DrawPenaltyCard) {
      yield* _mapDrawPenaltyCardToState(event);
    }
  }

  @override
  Future<void> close() async {
    await gameSub?.cancel();
    super.close();
  }

  Stream<CurrentGameState> _mapStartGameToState(StartGame event) async* {
    yield CurrentGameStarting();

    try {
      _self = event.self;
      final success = await _setupBlocAndSubscription(event.gameId);
      final game = networkService.currentGame;
      if (_self.isHost) {
        game.start();
        _self = Player.getPlayerFromList(game.players, _self.id);
        if (success) {
          await networkService.updateGameData(game);
        } else {
          yield CurrentGameStartingFailed();
        }
      }
    } on dynamic catch (e, s) {
      yield CurrentGameStartingFailed();
      await LogService.instance.recordError(e, s);
    }
  }

  Stream<CurrentGameState> _mapOpenGameWaitingLobbyToState(
    OpenGameWaitingLobby event,
  ) async* {
    yield CurrentGameStarting();
    try {
      _self = event.self;
      final success = await _setupBlocAndSubscription(event.gameId);
      if (success && _self.isHost) {
        var game = _currentGame;
        game = game.copyWith(state: GameState.waitingForPlayer);
        await networkService.updateGameData(
          <String, dynamic>{
            "state": "waitingForPlayer",
          },
        );
        yield CurrentGameWaitingForPlayer(game: game, self: _self);
      } else {
        yield CurrentGameStartingFailed();
      }
    } on dynamic catch (e, s) {
      await LogService.instance.recordError(e, s);
      yield CurrentGameStartingFailed();
    }
  }

  Stream<CurrentGameState> _mapUpdateCurrentGameToState(
    UpdateCurrentGame event,
  ) async* {
    try {
      _self = Player.getPlayerFromList(event.game.players, _playerId);
      if (_previousGame.players.length < event.game.players.length) {
        final joinedPlayer = getDiffInPlayerLists(
          event.game.players,
          _previousGame.players,
        );

        if (joinedPlayer != null) {
          DialogInformationService.instance.showNotification(
            NotificationType.information,
            config: NotificationConfiguration(
              content: '${joinedPlayer.name} ist dem Spiel beigetreten.',
            ),
          );
        }
      } else if (_previousGame.players.length > event.game.players.length) {
        final leavedPlayer = getDiffInPlayerLists(
          _previousGame.players,
          event.game.players,
        );
        if (leavedPlayer != null) {
          DialogInformationService.instance.showNotification(
            NotificationType.information,
            config: NotificationConfiguration(
              content: '${leavedPlayer.name} hat das Spiel verlassen.',
            ),
          );
        }
      }

      if (_previousGame.allowedCardColor != event.game.allowedCardColor) {
        if (event.game.playedCardStack.isNotEmpty &&
            (event.game.playedCardStack.last.number == CardNumber.jack ||
                event.game.playedCardStack.last.number == CardNumber.joker)) {
          yield UserChangedAllowedCardColor(event.game.allowedCardColor);
        } else {
          yield const UserChangedAllowedCardColor(null);
        }
      }

      if (_previousGame.message != event.game.message &&
          event.game.message != null) {
        DialogInformationService.instance.showNotification(
          NotificationType.content,
          config: NotificationConfiguration(
            content: event.game.message,
          ),
        );
      }

      switch (event.game.state) {
        case GameState.finished:
          add(EndGame());
          return;
        case GameState.waitingForPlayer:
          yield CurrentGameWaitingForPlayer(
            game: event.game,
            self: _self,
          );
          break;
        default:
          yield CurrentGameLoaded(
            game: event.game,
            self: _self,
          );
      }
    } on dynamic catch (e, s) {
      await LogService.instance.recordError(e, s);
    }
  }

  Stream<CurrentGameState> _mapLeaveGameToState(LeaveGame event) async* {
    try {
      await _leaveGame();
      _self = null;
      InformationStorage.instance.clearInformations();
      yield CurrentGameEmpty();
    } on GameLeaveException catch (e) {
      if (e.subscriptionCanceled) {
        gameSub = networkService.gameChangedStream
            .listen((game) => add(UpdateCurrentGame(game)));
      }
    }
  }

  Stream<CurrentGameState> _mapEndGameToState(EndGame event) async* {
    await gameSub.cancel();
    if (_self.isHost) {
      await networkService.updateGameData(
        <String, dynamic>{
          "state": "finished",
        },
      );

      await Future.delayed(
        const Duration(seconds: 2),
        () async => networkService.deleteGame(_currentGame.gameID),
      );
    }
    _self = null;
    InformationStorage.instance.clearInformations();
    yield CurrentGameFinished();
  }

  Stream<CurrentGameState> _mapPlayCardToState(PlayCard event) async* {
    try {
      final message = Rules.checkRules(_currentGame, event.card, _playerId);
      var shouldYieldWaitForBingo = false, isSuperBingo = false;

      if (message == null) {
        final game = _currentGame;

        int cardDrawAmount;
        var isJokerOrJackAllowed = true;
        var playerOrder = game.playerOrder;

        if (_self.cards.length - 1 <= 1) {
          shouldYieldWaitForBingo = true;
          isSuperBingo = _self.cards.length - 1 == 0;
        }
        _self.cards.removeWhere((c) => c == event.card);
        switch (event.card.rule) {
          case SpecialRule.reverse:
            playerOrder = game.reversePlayerOrder();
            break;
          case SpecialRule.plusTwo:
            cardDrawAmount =
                game.cardDrawAmount == 1 ? 2 : game.cardDrawAmount + 2;
            break;
          case SpecialRule.joker:
            isJokerOrJackAllowed = false;
            game.allowedCardColor = event.allowedCardColor;
            break;
          default:
            isJokerOrJackAllowed = true;
            game.allowedCardColor = null;
            break;
        }

        game.playedCardStack.add(event.card);
        game.updatePlayer(_self);

        if (game.playedCardStack.length >= 15 && _self.isHost) {
          game.cleanUpCardStacks();
        }

        yield CurrentGameLoaded(
          game: game,
          self: _self,
        );

        final nextPlayerId = game.getNextPlayerId();

        final filledGame = game.copyWith(
          currentPlayerId: nextPlayerId,
          players: game.players,
          isJokerOrJackAllowed: isJokerOrJackAllowed,
          cardDrawAmount: cardDrawAmount,
          playerOrder: playerOrder,
        );

        if (shouldYieldWaitForBingo) {
          yield WaitForBingoCall(isSuperBingo: isSuperBingo);
          yield CurrentGameLoaded(
            game: game,
            self: _self,
          );
        }
        await networkService.updateGameData(filledGame);
      } else {
        DialogInformationService.instance.showNotification(
          NotificationType.error,
          config: NotificationConfiguration(
            content: message,
          ),
        );
      }
    } on dynamic catch (e, s) {
      await LogService.instance.recordError(e, s);
    }
  }

  Stream<CurrentGameState> _mapDrawCardToState(DrawCard event) async* {
    var game = _currentGame;
    if (game.isRunning) {
      if (game.currentPlayerId == _self.id) {
        _self = Player.getPlayerFromList(game.players, _self.id);
        for (var i = 0; i < game.cardDrawAmount; i++) {
          final card = game.unplayedCardStack.removeFirst();
          _self.cards.add(card);
        }
        _self.cards.sort((a, b) => a.compareTo(b));
        if (game.cardDrawAmount <= 2) {
          final nextPlayerId = game.getNextPlayerId();
          game = game.copyWith(currentPlayerId: nextPlayerId);
        }
        game.allowedCardColor = null;
        game = game.copyWith(
          cardDrawAmount: 1,
          isJokerOrJackAllowed: true,
        );
        game.updatePlayer(_self);
        await networkService.updateGameData(game);
      } else {
        DialogInformationService.instance.showNotification(
          NotificationType.error,
          config: const NotificationConfiguration(
            content: 'Du bist nicht an der Reihe',
          ),
        );
      }
    }
  }

  Stream<CurrentGameState> _mapDrawPenaltyCardToState(
    DrawPenaltyCard event,
  ) async* {
    yield* _mapDrawCardToState(const DrawCard());
  }

  /// Ruft das Spiel, welches gestartet werden soll ab und setzt alle Variablen im Bloc.
  /// Außerdem wird die StreamSubscription gestartet.
  ///
  /// Gab es beim Ausführen der Methode keine Fehler wird die Funktion mit `true` beendet,
  /// tritt ein Fehler auf mit `false`.
  Future<bool> _setupBlocAndSubscription(String gameId) async {
    if (gameId != null) {
      try {
        await networkService.setupSubscription(gameId);
        gameSub = networkService.gameChangedStream
            .listen((game) => add(UpdateCurrentGame(game)));
        return true;
      } on dynamic catch (e, s) {
        await LogService.instance.recordError(e, s);
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> _leaveGame() async {
    try {
      final game = _currentGame;
      await gameSub?.cancel();
      game.removePlayer(_self);
      if (_self.isHost) {
        if (game.players.isNotEmpty) {
          game.players[0] = game.players[0].copyWith(isHost: true);
        } else {
          await networkService.deleteGame(gameId);
          return;
        }
      }
      final nextPlayerId = game.getNextPlayerId();
      game.currentPlayerId = nextPlayerId ?? game.players.firstOrNull()?.id;
      await networkService.updateGameData(game);
    } on dynamic catch (e, s) {
      await LogService.instance.recordError(e, s);
      throw GameLeaveException(subscriptionCanceled: gameSub == null);
    }
  }

  Player getDiffInPlayerLists(List<Player> newList, List<Player> oldList) {
    final diffPlayer = newList.firstWhere(
      (p) => oldList.indexWhere((oldPlayer) => p.id == oldPlayer.id) == -1,
      orElse: () => null,
    );

    return diffPlayer;
  }
}

class GameLeaveException implements Exception {
  final bool subscriptionCanceled;

  const GameLeaveException({@required this.subscriptionCanceled});
}
