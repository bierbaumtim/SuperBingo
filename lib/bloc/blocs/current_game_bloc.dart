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

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// {@template currentgamebloc}
///
/// {@endtemplate}
class CurrentGameBloc extends Bloc<CurrentGameEvent, CurrentGameState> {
  final Firestore db;
  StreamSubscription gameSub;
  String get gameId => InformationStorage.instance.gameId;
  String get gameLink => InformationStorage.instance.gameLink;
  String get _playerId => InformationStorage.instance.playerId;
  Game _game;
  Player _self;

  /// {@macro currentgamebloc}
  CurrentGameBloc(this.db);

  @override
  CurrentGameState get initialState => CurrentGameEmpty();

  @override
  Stream<CurrentGameState> mapEventToState(CurrentGameEvent event) async* {
    if (event is StartGame) {
      yield* _mapStartGameToState(event);
    } else if (event is OpenGameWaitingLobby) {
      yield* _mapStartGameWaitingLobbyToState(event);
    } else if (event is LeaveGame) {
      yield* _mapLeaveGameToState(event);
    } else if (event is EndGame) {
    } else if (event is UpdateCurrentGame) {
      yield* _mapUpdateCurrentGameToState(event);
    } else if (event is PlayCard) {
      yield* _mapPlayCardToState(event);
    } else if (event is PullCard) {
      yield* _mapPullCardToState(event);
    }
  }

  @override
  Future<void> close() async {
    gameSub?.cancel();
    super.close();
  }

  Stream<CurrentGameState> _mapStartGameToState(StartGame event) async* {
    yield CurrentGameStarting();
    try {
      _self = event.self;
      final success = await _setupBlocAndSubscription(event.gameId);
      if (success) {
        _game.state = GameState.active;
        _game.currentPlayerId = _game.players.first.id;
        await _updateGameData(_game);
      } else {
        yield CurrentGameStartingFailed();
      }
    } on dynamic catch (e, s) {
      await Crashlytics.instance.recordError(e, s);
      yield CurrentGameStartingFailed();
    }
  }

  Stream<CurrentGameState> _mapStartGameWaitingLobbyToState(
      OpenGameWaitingLobby event) async* {
    yield CurrentGameStarting();
    try {
      _self = event.self;
      final success = await _setupBlocAndSubscription(event.gameId);
      if (success) {
        // var game = await _getGameSnapshot(event.gameId);
        _game = _game.copyWith(state: GameState.waitingForPlayer);
        await _updateGameData(_game);
        yield CurrentGameWaitingForPlayer(game: _game, self: _self);
      } else {
        yield CurrentGameStartingFailed();
      }
    } on dynamic catch (e, s) {
      await Crashlytics.instance.recordError(e, s);
      yield CurrentGameStartingFailed();
    }
  }

  Stream<CurrentGameState> _mapUpdateCurrentGameToState(
      UpdateCurrentGame event) async* {
    try {
      final self = Player.getPlayerFromList(event.game.players, _playerId);
      if (_game.players.length < event.game.players.length) {
        final joinedPlayer = getDiffInPlayerLists(
          event.game.players,
          _game.players,
        );

        if (joinedPlayer != null) {
          yield PlayerJoined(joinedPlayer);
        }
      } else if (_game.players.length > event.game.players.length) {
        final leavedPlayer = getDiffInPlayerLists(
          _game.players,
          event.game.players,
        );
        if (leavedPlayer != null) {
          yield PlayerLeaved(leavedPlayer);
        }
      }
      _game = event.game;
      if (_game.state == GameState.waitingForPlayer) {
        yield CurrentGameWaitingForPlayer(
          game: _game,
          self: _self,
        );
      } else {
        yield CurrentGameLoaded(
          game: event.game,
          handCards: self.cards,
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
        gameSub = db
            .collection('games')
            .document(gameId)
            .snapshots()
            .listen(_handleNetworkDataChange);
      }
    }
  }

  Stream<CurrentGameState> _mapPlayCardToState(PlayCard event) async* {
    try {
      final message = _checkRules(event.card);

      if (message == null) {
        _self.cards.removeWhere((c) => c == event.card);
        if (event.card.rule == SpecialRule.reverse) {
          _game.players = _game.players.reversed.toList();
        }
        final nextPlayer = _self.getNextPlayer(
          _game.players,
          skipNextPlayer: event.card.rule == SpecialRule.skip,
        );
        _game.updatePlayer(_self);
        var filledGame = _game.copyWith(
          playedCardStack: _game.playedCardStack..add(event.card),
          currentPlayerId: nextPlayer.id,
          players: _game.players,
        );

        await _updateGameData(filledGame);
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

  Stream<CurrentGameState> _mapPullCardToState(PullCard event) async* {
    // final game = await _getGameSnapshot(gameId);
    if (_game.isRunning) {
      final card = _game.unplayedCardStack.removeFirst();
      _self = Player.getPlayerFromList(_game.players, _self.id);
      _self.cards.add(card);
      _game.players = _game.players
          .map((player) => player.id == _self.id ? _self : player)
          .toList();
      await _updateGameData(_game);
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
        final snapshot = await db.collection('games').document(gameId).get();
        _game = Game.fromJson(snapshot.data);
        gameSub = db
            .collection('games')
            .document(gameId)
            .snapshots()
            .listen(_handleNetworkDataChange);
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
      // var game = await _getGameSnapshot(gameId);
      _game.removePlayer(_self);
      await gameSub.cancel();
      if (_self.isHost) {
        if (_game.players.isNotEmpty) {
          _game.players[0] = _game.players[0].copyWith(isHost: true);
        } else {
          await db.collection('games').document(gameId).delete();
          return;
        }
      }

      final gameDBData =
          await compute<Game, Map<String, dynamic>>(Game.toDBData, _game);
      await db.collection('games').document(gameId).updateData(gameDBData);
    } on dynamic catch (e, s) {
      await Crashlytics.instance.recordError(e, s);
      throw GameLeaveException(subscriptionCanceled: gameSub == null);
    }
  }

  Future<Game> _getGameSnapshot(String gameId) async {
    final snapshot = await db.collection('games').document(gameId).get();
    return Game.fromJson(snapshot.data);
  }

  Future<void> _updateGameData(Game game) async {
    final dbGame =
        await compute<Game, Map<String, dynamic>>(Game.toDBData, game);
    await db.collection('games').document(game.gameID).updateData(dbGame);
  }

  void _handleNetworkDataChange(DocumentSnapshot snapshot) async {
    final game = Game.fromJson(snapshot.data);
    add(UpdateCurrentGame(game));
  }

  String _checkRules(GameCard card) {
    if (_game.currentPlayerId != _playerId) return 'Du bist nicht an der Reihe';
    if (!Rules.isCardAllowed(card, _game.topCard)) {
      return 'Du darfst diese Karte nicht legen';
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
