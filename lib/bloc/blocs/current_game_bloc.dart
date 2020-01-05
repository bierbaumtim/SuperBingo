import 'dart:async';

import 'package:superbingo/bloc/events/current_game_events.dart';
import 'package:superbingo/bloc/states/current_game_states.dart';
import 'package:superbingo/constants/enums.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/models/app_models/game.dart';
import 'package:superbingo/models/app_models/player.dart';
import 'package:superbingo/models/app_models/rules.dart';
import 'package:superbingo/service/dialog_information_service.dart';
import 'package:superbingo/service/information_storage.dart';
import 'package:superbingo/services/network_service.dart';

import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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
  CurrentGameBloc(this.networkService);

  @override
  CurrentGameState get initialState => CurrentGameEmpty();

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
      await Crashlytics.instance.recordError(e, s);
      yield CurrentGameStartingFailed();
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
      await Crashlytics.instance.recordError(e, s);
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
          yield PlayerJoined(joinedPlayer);
        }
      } else if (_previousGame.players.length > event.game.players.length) {
        final leavedPlayer = getDiffInPlayerLists(
          _previousGame.players,
          event.game.players,
        );
        if (leavedPlayer != null) {
          yield PlayerLeaved(leavedPlayer);
        }
      }
      if (event.game.state == GameState.finished) {
        add(EndGame());
        return;
      }
      if (event.game.state == GameState.waitingForPlayer) {
        yield CurrentGameWaitingForPlayer(
          game: event.game,
          self: _self,
        );
      } else {
        yield CurrentGameLoaded(
          game: event.game,
          handCards: _self.cards,
          playedCards: event.game.playedCardStack.toList(),
          unplayedCards: event.game.unplayedCardStack.toList(),
        );
      }
    } on dynamic catch (e, s) {
      await Crashlytics.instance.recordError(e, s);
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
        Duration(seconds: 2),
        () async => await networkService.deleteGame(_currentGame.gameID),
      );
    }
    _self = null;
    InformationStorage.instance.clearInformations();
    yield CurrentGameFinished();
  }

  Stream<CurrentGameState> _mapPlayCardToState(PlayCard event) async* {
    try {
      final currentState = state;
      final message = _checkRules(event.card);

      if (message == null) {
        if (_self.cards.length - 1 <= 1) {
          yield WaitForBingoCall(isSuperBingo: _self.cards.length - 1 == 0);
          yield currentState;
        }
        _self.cards.removeWhere((c) => c == event.card);
        final game = _currentGame;
        if (event.card.rule == SpecialRule.reverse) {
          game.players = game.reversePlayerOrder();
        }
        if (event.card.rule == SpecialRule.plusTwo) {
          game.cardDrawAmount =
              game.cardDrawAmount == 1 ? 2 : game.cardDrawAmount + 2;
        }
        if (event.card.rule == SpecialRule.joker) {
          game.isJokerOrJackAllowed = false;
          game.allowedCardColor = event.allowedCardColor;
        } else {
          game.isJokerOrJackAllowed = true;
          game.allowedCardColor = null;
        }
        final nextPlayer = _self.getNextPlayer(
          game.players,
          skipNextPlayer: event.card.rule == SpecialRule.skip,
        );
        game.updatePlayer(_self);
        var filledGame = game.copyWith(
          playedCardStack: game.playedCardStack..add(event.card),
          currentPlayerId: nextPlayer.id,
          players: game.players,
        );

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
      await Crashlytics.instance.recordError(e, s);
    }
  }

  Stream<CurrentGameState> _mapDrawCardToState(DrawCard event) async* {
    final game = _currentGame;
    if (game.isRunning) {
      if (game.currentPlayerId == _self.id) {
        game.isJokerOrJackAllowed = true;
        game.allowedCardColor = null;
        _self = Player.getPlayerFromList(game.players, _self.id);
        for (var i = 0; i < game.cardDrawAmount; i++) {
          final card = game.unplayedCardStack.removeFirst();
          _self.cards.add(card);
        }
        game.cardDrawAmount = 1;
        game.updatePlayer(_self);
        await networkService.updateGameData(game);
      } else {
        DialogInformationService.instance.showNotification(
          NotificationType.error,
          config: NotificationConfiguration(
            content: 'Du bist nicht an der Reihe',
          ),
        );
      }
    }
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
        await Crashlytics.instance.recordError(e, s);
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> _leaveGame() async {
    try {
      final game = _currentGame;
      await gameSub.cancel();
      game.removePlayer(_self);
      if (_self.isHost) {
        if (game.players.isNotEmpty) {
          game.players[0] = game.players[0].copyWith(isHost: true);
          await networkService.updateGameData(game);
        } else {
          await networkService.deleteGame(gameId);
          return;
        }
      }
    } on dynamic catch (e, s) {
      await Crashlytics.instance.recordError(e, s);
      throw GameLeaveException(subscriptionCanceled: gameSub == null);
    }
  }

  String _checkRules(GameCard card) {
    final game = _currentGame;
    if (game.currentPlayerId != _playerId) {
      return 'Du bist nicht an der Reihe!';
    }
    if (!game.isJokerOrJackAllowed && card.rule == SpecialRule.joker) {
      return 'Du darfst keine zwei Joker/Buben aufeinander legen!';
    }
    if (game.allowedCardColor != null && game.allowedCardColor != card.color) {
      return 'Der letzte Spieler hat sich eine andere Farbe gewünscht. Du darfst diese Karte daher nicht legen!';
    }
    if (game.cardDrawAmount > 1 && card.number != CardNumber.seven) {
      return 'Du musst ${game.cardDrawAmount} Karten ziehen!';
    }
    if (!Rules.isCardAllowed(card, game.topCard)) {
      return 'Du darfst diese Karte nicht legen!';
    }

    return null;
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

  GameLeaveException({this.subscriptionCanceled});
}
