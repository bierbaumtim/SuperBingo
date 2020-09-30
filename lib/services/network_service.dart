import 'dart:async';

import 'package:firedart/firedart.dart';
import 'package:flutter/foundation.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:rxdart/rxdart.dart';

import '../models/app_models/game.dart';
import '../models/app_models/player.dart';

abstract class INetworkService {
  const INetworkService();

  Firestore get db;
  Game get previousGame;
  Game get currentGame;
  Stream<Game> get gameChangedStream;

  Future<bool> setupSubscription(String gameId);

  Future<Document> addGame(Game game);

  Future<void> deleteGame(String gameId);

  Future<void> updateGameData(dynamic data, [String gameId]);

  Future<void> cancelSubscription();

  Future<void> restoreHandCards(String playerId);

  Future<void> dispose();
}

/// `NetworkService` provides all functions needed for online multiplayer part of the game.
/// Every incoming and outgoing data will be processed by it.
class NetworkService implements INetworkService {
  final Firestore _db;
  Game _previousGame, _currentGame;
  BehaviorSubject<Game> _gameChangedController;
  StreamSubscription<Game> _gameSub;

  NetworkService(this._db) {
    _gameChangedController = BehaviorSubject<Game>();
  }

  @override
  Firestore get db => _db;
  @override
  Game get previousGame => _previousGame;
  @override
  Game get currentGame => _currentGame;
  @override
  Stream<Game> get gameChangedStream => _gameChangedController.stream;

  @override
  Future<bool> setupSubscription(String gameId) async {
    if (gameId != null) {
      try {
        final snapshot = await db.collection('games').document(gameId).get();
        _currentGame = Game.fromJson(snapshot.map);
        _gameSub = db
            .collection('games')
            .document(gameId)
            .stream
            .asyncMap(_convertDBDataStreamEvent)
            .listen(_handleNewGameStreamEvent);
        return true;
      } on dynamic catch (e, s) {
        await FirebaseCrashlytics.instance.recordError(e, s);
      }
    }
    return false;
  }

  @override
  Future<Document> addGame(Game game) async {
    final gameDBData =
        await compute<Game, Map<String, dynamic>>(Game.toDBData, game);

    return db.collection('games').add(gameDBData);
  }

  @override
  Future<void> deleteGame(String gameId) async {
    await db.collection('games').document(gameId).delete();
    await cancelSubscription();
    _previousGame = null;
    _currentGame = null;
  }

  @override
  Future<void> updateGameData(dynamic data, [String gameId]) async {
    if (data is Game) {
      final dbGame =
          await compute<Game, Map<String, dynamic>>(Game.toDBData, data);
      await db.collection('games').document(data.gameID).update(dbGame);
    } else if (data is Map<String, dynamic>) {
      assert(gameId != null || _currentGame?.gameID != null);
      await db
          .collection('games')
          .document(gameId ?? _currentGame.gameID)
          .update(data);
    }
  }

  @override
  Future<void> restoreHandCards(String playerId) async {
    try {
      final player = Player.getPlayerFromList(previousGame.players, playerId);
      final cards = player?.cards;
      var currentPlayer =
          Player.getPlayerFromList(currentGame.players, playerId);
      currentPlayer = currentPlayer.copyWith(
        cards: cards,
      );
      final game = currentGame;
      game.updatePlayer(currentPlayer);
      return updateGameData(game);
    } on dynamic catch (e, s) {
      await FirebaseCrashlytics.instance.recordError(e, s);
    }
  }

  @override
  Future<void> cancelSubscription() async {
    await _gameSub.cancel();
  }

  @override
  Future<void> dispose() async {
    await _gameChangedController.close();
    await cancelSubscription();
  }

  Future<Game> _convertDBDataStreamEvent(Document snapshot) async {
    return Game.fromJson(snapshot.map);
  }

  void _handleNewGameStreamEvent(Game newGame) {
    if (newGame != null) {
      _previousGame = _currentGame;
      _currentGame = newGame;
      _gameChangedController.sink.add(_currentGame);
    } else {
      FirebaseCrashlytics.instance
          .recordError('newGame is null: $newGame', StackTrace.current);
    }
  }
}

/// Actions describing the current game state.
/// Also each actions are indicators for the UI to start animations or other stuff
enum Action { playCard, startGame, dealCards }
