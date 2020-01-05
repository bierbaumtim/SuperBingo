import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:superbingo/models/app_models/game.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:rxdart/rxdart.dart';

abstract class INetworkService {
  Firestore get db;
  Game get previousGame;
  Game get currentGame;
  Stream<Game> get gameChangedStream;

  Future<bool> setupSubscription(String gameId);

  Future<DocumentReference> addGame(Game game);

  Future<void> deleteGame(String gameId);

  Future<void> updateGameData(dynamic data, [String gameId]);

  Future<void> cancelSubscription();

  Future<void> dispose();
}

/// `NetworkService` provides all functions needed for online multiplayer part of the game.
/// Every incoming and outgoing data will be processed by it.
class NetworkService implements INetworkService {
  Game _previousGame, _currentGame;
  BehaviorSubject<Game> _gameChangedController;
  StreamSubscription<Game> _gameSub;

  // static final NetworkService instance = NetworkService._internal();

  // factory NetworkService() => instance;

  NetworkService() {
    _gameChangedController = BehaviorSubject<Game>();
  }

  Firestore get db => Firestore.instance;
  Game get previousGame => _previousGame;
  Game get currentGame => _currentGame;
  Stream<Game> get gameChangedStream => _gameChangedController.stream;

  Future<bool> setupSubscription(String gameId) async {
    if (gameId != null) {
      try {
        final snapshot = await db.collection('games').document(gameId).get();
        _currentGame = Game.fromJson(snapshot.data);
        _gameSub = db
            .collection('games')
            .document(gameId)
            .snapshots()
            .asyncMap(_convertDBDataStreamEvent)
            .listen(_handleNewGameStreamEvent);
        return true;
      } on dynamic catch (e, s) {
        await Crashlytics.instance.recordError(e, s);
      }
    }
    return false;
  }

  Future<DocumentReference> addGame(Game game) async {
    final gameDBData =
        await compute<Game, Map<String, dynamic>>(Game.toDBData, game);

    return db.collection('games').add(gameDBData);
  }

  Future<void> deleteGame(String gameId) async {
    await db.collection('games').document(gameId).delete();
    _previousGame = null;
    _currentGame = null;
  }

  Future<void> updateGameData(dynamic data, [String gameId]) async {
    if (data is Game) {
      final dbGame =
          await compute<Game, Map<String, dynamic>>(Game.toDBData, data);
      await db.collection('games').document(data.gameID).updateData(dbGame);
    } else if (data is Map<String, dynamic>) {
      assert(gameId != null || _currentGame?.gameID != null);
      await db
          .collection('games')
          .document(gameId ?? _currentGame.gameID)
          .updateData(data);
    }
  }

  Future<void> cancelSubscription() async {
    await _gameSub.cancel();
  }

  Future<void> dispose() async {
    await _gameChangedController.close();
    await cancelSubscription();
  }

  Future<Game> _convertDBDataStreamEvent(DocumentSnapshot snapshot) async {
    return Game.fromJson(snapshot.data);
  }

  void _handleNewGameStreamEvent(Game newGame) {
    if (newGame != null) {
      _previousGame = _currentGame;
      _currentGame = newGame;
      _gameChangedController.sink.add(_currentGame);
    } else {
      Crashlytics.instance
          .recordError('newGame is null: $newGame', StackTrace.current);
    }
  }
}

/// Actions describing the current game state.
/// Also each actions are indicators for the UI to start animations or other stuff
enum Action { playCard, startGame, dealCards }
