import 'dart:async';

import 'package:bloc/bloc.dart';

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

// ignore_for_file: avoid_print
/// {@template currentgamebloc}
///
/// {@endtemplate}
class CurrentGameBloc extends Bloc<CurrentGameEvent, CurrentGameState> {
  final INetworkService networkService;
  StreamSubscription? gameSub;
  String get gameId => InformationStorage.instance.gameId;
  String get gameLink => InformationStorage.instance.gameLink;
  String get _playerId => InformationStorage.instance.playerId;
  Player? _self;

  Game? get _currentGame => networkService.currentGame;
  Game? get _previousGame => networkService.previousGame;

  /// {@macro currentgamebloc}
  CurrentGameBloc(this.networkService) : super(CurrentGameEmpty()) {
    on<StartGame>(_handleStartGame);
    on<OpenGameWaitingLobby>(_handleOpenGameWaitingLobby);
    on<LeaveGame>(_mapLeaveGameToState);
    on<EndGame>(_handleEndGame);
    on<UpdateCurrentGame>(_handleUpdateCurrentGame);
    on<PlayCard>(_handlePlayCard);
    on<DrawCard>(_handleDrawCard);
    on<DrawPenaltyCard>(_handleDrawPenaltyCard);
  }

  @override
  Future<void> close() async {
    await gameSub?.cancel();
    super.close();
  }

  Future<void> _handleStartGame(
    StartGame event,
    Emitter<CurrentGameState> emit,
  ) async {
    emit(CurrentGameStarting());

    try {
      _self = event.self;
      final success = await _setupBlocAndSubscription(event.gameId);
      final game = networkService.currentGame;
      if (_self!.isHost && game != null) {
        game.start();
        _self = Player.getPlayerFromList(game.players, _self!.id);
        if (success) {
          await networkService.updateGameData(game);
          print('Game started: $game');
        } else {
          emit(CurrentGameStartingFailed());
        }
      }
    } on Object catch (e, s) {
      emit(CurrentGameStartingFailed());
      await LogService.instance.recordError(e, s);
    }
  }

  Future<void> _handleOpenGameWaitingLobby(
    OpenGameWaitingLobby event,
    Emitter<CurrentGameState> emit,
  ) async {
    emit(CurrentGameStarting());
    try {
      _self = event.self;
      final success = await _setupBlocAndSubscription(event.gameId);
      if (success && _self!.isHost) {
        var game = _currentGame;
        game = game!.copyWith(state: GameState.waitingForPlayer);
        await networkService.updateGameData(
          <String, dynamic>{
            "state": "waitingForPlayer",
          },
        );
        print('Game-Lobby ist offen.');
        emit(CurrentGameWaitingForPlayer(game: game, self: _self!));
      } else {
        emit(CurrentGameStartingFailed());
      }
    } on Object catch (e, s) {
      await LogService.instance.recordError(e, s);
      emit(CurrentGameStartingFailed());
    }
  }

  Future<void> _handleUpdateCurrentGame(
    UpdateCurrentGame event,
    Emitter<CurrentGameState> emit,
  ) async {
    print('=========== UpdateCurrentGame started ===========');
    try {
      _self = Player.getPlayerFromList(event.game.players, _playerId);
      if (_previousGame != null &&
          _previousGame!.players.length < event.game.players.length) {
        final joinedPlayer = getDiffInPlayerLists(
          event.game.players,
          _previousGame!.players,
        );

        if (joinedPlayer != null) {
          print('${joinedPlayer.name} ist dem Spiel beigetreten.');
          DialogInformationService.instance.showNotification(
            NotificationType.information,
            config: NotificationConfiguration(
              content: '${joinedPlayer.name} ist dem Spiel beigetreten.',
            ),
          );
        }
      } else if (_previousGame != null &&
          _previousGame!.players.length > event.game.players.length) {
        final leavedPlayer = getDiffInPlayerLists(
          _previousGame!.players,
          event.game.players,
        );
        if (leavedPlayer != null) {
          print('${leavedPlayer.name} hat das Spiel verlassen.');
          DialogInformationService.instance.showNotification(
            NotificationType.information,
            config: NotificationConfiguration(
              content: '${leavedPlayer.name} hat das Spiel verlassen.',
            ),
          );
        }
      }

      print('AllowedCardColor changed: ${event.game.allowedCardColor}');
      emit(UserChangedAllowedCardColor(event.game.allowedCardColor));

      if (_previousGame != null &&
          _previousGame!.message != event.game.message &&
          event.game.message.isNotEmpty) {
        print('New message available: ${event.game.message}');
        DialogInformationService.instance.showNotification(
          NotificationType.content,
          config: NotificationConfiguration(
            content: event.game.message,
          ),
        );
      }

      final currentState = state;

      switch (event.game.state) {
        case GameState.finished:
          await _handleEndGame(EndGame(), emit);
          return;
        case GameState.waitingForPlayer:
          emit(
            CurrentGameWaitingForPlayer(
              game: event.game,
              self: _self!,
            ),
          );
          break;
        default:
          emit(
            CurrentGameLoaded(
              game: event.game,
              self: _self!,
            ),
          );
      }

      if (state is CurrentGameLoaded) {
        print(
          'Game Equality check: ${_currentGame != (state as CurrentGameLoaded).game}',
        );
      }
      print('State Equality check: ${currentState != state}');
    } on Object catch (e, s) {
      await LogService.instance.recordError(e, s);
    }
    print('=========== UpdateCurrentGame ended ===========');
  }

  Future<void> _mapLeaveGameToState(
    LeaveGame event,
    Emitter<CurrentGameState> emit,
  ) async {
    try {
      await _leaveGame();
      _self = null;
      InformationStorage.instance.clearInformations();
      emit(CurrentGameEmpty());
    } on GameLeaveException catch (e) {
      if (e.subscriptionCanceled) {
        gameSub = networkService.gameChangedStream
            .listen((game) => add(UpdateCurrentGame(game)));
      }
    }
  }

  Future<void> _handleEndGame(
    EndGame event,
    Emitter<CurrentGameState> emit,
  ) async {
    await gameSub!.cancel();
    await networkService.cancelSubscription();
    if (_self!.isHost) {
      await networkService.updateGameData(
        <String, dynamic>{
          "state": "finished",
        },
      );
      print('Game Ended');

      await Future.delayed(
        const Duration(seconds: 2),
        () async => networkService.deleteGame(_currentGame!.gameID),
      );
    }
    _self = null;
    InformationStorage.instance.clearInformations();
    emit(CurrentGameFinished());
  }

  Future<void> _handlePlayCard(
    PlayCard event,
    Emitter<CurrentGameState> emit,
  ) async {
    print('=========== PlayCard started ===========');
    try {
      final message = Rules.checkRules(_currentGame!, event.card, _playerId);
      var shouldYieldWaitForBingo = false, isSuperBingo = false;

      if (message.isEmpty) {
        Game game = _currentGame!;

        switch (event.card.rule) {
          case SpecialRule.reverse:
            game.reversePlayerOrder();
            game.allowedCardColor = null;
            break;
          case SpecialRule.plusTwo:
            game = game.copyWith(
              cardDrawAmount:
                  game.cardDrawAmount == 1 ? 2 : game.cardDrawAmount + 2,
            );
            game.allowedCardColor = null;
            break;
          case SpecialRule.joker:
            game.copyWith(
              isJokerOrJackAllowed: false,
            );
            game.allowedCardColor = event.allowedCardColor;
            break;
          default:
            game.copyWith(
              isJokerOrJackAllowed: true,
            );
            game.allowedCardColor = null;
            break;
        }

        if (_self!.cards.length - 1 <= 1) {
          shouldYieldWaitForBingo = true;
          isSuperBingo = _self!.cards.length - 1 == 0;
        }

        _self!.cards.removeWhere((c) => c == event.card);

        game.playedCardStack.add(event.card);
        game.updatePlayer(_self!);

        if (game.playedCardStack.length >= 15 && _self!.isHost) {
          game.cleanUpCardStacks();
        }

        /// Nächsten Spieler nur ermitteln,
        /// wenn das Spiel nachdem legen der Karte nicht beendet ist.
        if (!(isSuperBingo && game.predictEnd(self: _self))) {
          game.getNextPlayerId(
            rule: event.card.rule,
          );
        }

        final currentState = state;

        emit(
          CurrentGameLoaded(
            game: game,
            self: _self!,
          ),
        );

        print(
          'Game Equality check: ${_currentGame != (state as CurrentGameLoaded).game}',
        );
        print('State Equality check: ${currentState != state}');

        if (shouldYieldWaitForBingo) {
          emit(WaitForBingoCall(isSuperBingo: isSuperBingo));
          emit(
            CurrentGameLoaded(
              game: game,
              self: _self!,
            ),
          );
        }
        await networkService.updateGameData(game);
      } else {
        DialogInformationService.instance.showNotification(
          NotificationType.error,
          config: NotificationConfiguration(
            content: message,
          ),
        );
      }
    } on Object catch (e, s) {
      await LogService.instance.recordError(e, s);
    }

    print('=========== PlayCard ended ===========');
  }

  Future<void> _handleDrawCard(
    DrawCard event,
    Emitter<CurrentGameState> emit,
  ) async {
    Game game = _currentGame!;
    if (game.isRunning) {
      if (game.currentPlayerId == _self!.id) {
        _self = Player.getPlayerFromList(game.players, _self!.id);
        for (var i = 0; i < game.cardDrawAmount; i++) {
          final card = game.unplayedCardStack.removeFirst();
          _self!.cards.add(card);
        }
        _self!.cards.sort((a, b) => a.compareTo(b));

        game.getNextPlayerId();
        game = game.copyWith(
          cardDrawAmount: 1,
          isJokerOrJackAllowed: true,
        );
        game.updatePlayer(_self!);
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

  Future<void> _handleDrawPenaltyCard(
    DrawPenaltyCard event,
    Emitter<CurrentGameState> emit,
  ) async {
    final game = _currentGame!;
    if (game.isRunning) {
      final card = game.unplayedCardStack.removeFirst();
      _self!.cards.add(card);
      _self!.cards.sort((a, b) => a.compareTo(b));
      game.updatePlayer(_self!);
      await networkService.updateGameData(game);

      print('Strafkarte gezogen: $game');

      emit(
        CurrentGameLoaded(
          game: game,
          self: _self!,
        ),
      );
    }
  }

  /// Ruft das Spiel, welches gestartet werden soll ab und setzt alle Variablen im Bloc.
  /// Außerdem wird die StreamSubscription gestartet.
  ///
  /// Gab es beim Ausführen der Methode keine Fehler wird die Funktion mit `true` beendet,
  /// tritt ein Fehler auf mit `false`.
  Future<bool> _setupBlocAndSubscription(String gameId) async {
    if (gameId.isNotEmpty) {
      try {
        await networkService.setupSubscription(gameId);
        gameSub = networkService.gameChangedStream
            .listen((game) => add(UpdateCurrentGame(game)));
        return true;
      } on Object catch (e, s) {
        await LogService.instance.recordError(e, s);
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> _leaveGame() async {
    try {
      final game = _currentGame!;
      await gameSub?.cancel();
      await networkService.cancelSubscription();
      game.removePlayer(_self!);
      if (_self!.isHost) {
        if (game.players.isNotEmpty) {
          game.players[0] = game.players[0].copyWith(isHost: true);
        } else {
          await networkService.deleteGame(gameId);
          return;
        }
      }
      game.currentPlayerId = game.getNextPlayerId();
      await networkService.updateGameData(game);
    } on Object catch (e, s) {
      await LogService.instance.recordError(e, s);
      throw GameLeaveException(subscriptionCanceled: gameSub == null);
    }
  }

  Player? getDiffInPlayerLists(List<Player> newList, List<Player> oldList) {
    try {
      return newList.firstWhere(
        (p) => oldList.indexWhere((oldPlayer) => p.id == oldPlayer.id) == -1,
      );
    } catch (e) {
      return null;
    }
  }
}

class GameLeaveException implements Exception {
  final bool subscriptionCanceled;

  const GameLeaveException({required this.subscriptionCanceled});
}
