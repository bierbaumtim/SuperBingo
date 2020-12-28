import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/app_models/game.dart';
import '../../models/app_models/player.dart';
import '../log_service.dart';
import 'network_service_interface.dart';

/// `NetworkService` provides all functions needed for online multiplayer part of the game.
/// Every incoming and outgoing data will be processed by it.
class NetworkServiceMobile implements INetworkService {
  final FirebaseFirestore _db;
  Game _previousGame, _currentGame;
  BehaviorSubject<Game> _gameChangedController;
  BehaviorSubject<List<Game>> _publicGamesController;
  StreamSubscription<Game> _gameSub;
  StreamSubscription<QuerySnapshot> _publicGamesSub;

  NetworkServiceMobile(this._db) {
    _gameChangedController = BehaviorSubject<Game>();
    _publicGamesController = BehaviorSubject<List<Game>>.seeded(<Game>[]);
  }

  @override
  Game get previousGame => _previousGame;

  @override
  Game get currentGame => _currentGame;

  @override
  Stream<Game> get gameChangedStream => _gameChangedController.stream;

  @override
  Stream<List<Game>> get publicGamesStream => _publicGamesController.stream;

  @override
  Future<bool> setupSubscription(String gameId) async {
    if (gameId != null) {
      try {
        final snapshot = await _db.collection('games').doc(gameId).get();
        _currentGame = Game.fromJson(snapshot.data());
        _gameSub = _db
            .collection('games')
            .doc(gameId)
            .snapshots()
            .asyncMap(_convertDBDataStreamEvent)
            .listen(_handleNewGameStreamEvent);
        return true;
      } on dynamic catch (e, s) {
        await LogService.instance.recordError(e, s);
      }
    }
    return false;
  }

  @override
  Future<GameMetaInformation> addGame(Game game) async {
    final gameDBData =
        await compute<Game, Map<String, dynamic>>(Game.toDBData, game);

    final doc = await _db.collection('games').add(gameDBData);

    return GameMetaInformation(
      id: doc.id,
      path: doc.path,
    );
  }

  @override
  Future<Game> getGameById(String id) async {
    final snapshot = await _db.collection('games').doc(id).get();

    return Game.fromJson(snapshot.data());
  }

  @override
  Future<void> deleteGame(String gameId) async {
    await _db.collection('games').doc(gameId).delete();
    await cancelSubscription();
    _previousGame = null;
    _currentGame = null;
  }

  @override
  Future<void> updateGameData(dynamic data, [String gameId]) async {
    if (data is Game) {
      final dbGame =
          await compute<Game, Map<String, dynamic>>(Game.toDBData, data);
      await _db.collection('games').doc(data.gameID).update(dbGame);
    } else if (data is Map<String, dynamic>) {
      assert(gameId != null || _currentGame?.gameID != null);
      await _db
          .collection('games')
          .doc(gameId ?? _currentGame.gameID)
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
      await LogService.instance.recordError(e, s);
    }
  }

  @override
  Future<void> cancelSubscription() async {
    await _gameSub.cancel();
  }

  @override
  Future<void> dispose() async {
    await _gameChangedController.close();
    await _publicGamesController.close();
    await _publicGamesSub.cancel();
    await cancelSubscription();
  }

  Future<Game> _convertDBDataStreamEvent(DocumentSnapshot snapshot) async {
    return Game.fromJson(snapshot.data());
  }

  void _handleNewGameStreamEvent(Game newGame) {
    if (newGame != null) {
      _previousGame = _currentGame;
      _currentGame = newGame;
      _gameChangedController.sink.add(_currentGame);
    } else {
      LogService.instance
          .recordError('newGame is null: $newGame', StackTrace.current);
    }
  }

  @override
  Future<List<Game>> getPublicGames() async {
    try {
      final snapshot = await _db.collection('games').get();
      return _getPublicGamesFromQuerySnapshot(snapshot);
    } on dynamic catch (e, s) {
      LogService.instance.recordError(e, s);
      return <Game>[];
    }
  }

  @override
  void initPublicGamesStream() {
    _publicGamesSub =
        _db.collection('games').snapshots().listen(_handleSnapshot);
  }

  @override
  void pausePublicGamesStream() {
    _publicGamesSub.pause();
  }

  @override
  void resumePublicGamesStream() {
    _publicGamesSub.resume();
  }

  List<Game> _getPublicGamesFromQuerySnapshot(QuerySnapshot snapshot) {
    try {
      final games =
          snapshot.docs.map<Game>((g) => Game.fromJson(g.data())).toList();
      return games
          .where((game) =>
              game.isPublic && game.state == GameState.waitingForPlayer)
          .toList();
    } on dynamic catch (e, s) {
      LogService.instance.recordError(e, s);
      return <Game>[];
    }
  }

  void _handleSnapshot(QuerySnapshot snapshot) {
    try {
      _publicGamesController.sink
          .add(_getPublicGamesFromQuerySnapshot(snapshot));
    } on PlatformException catch (e) {
      if (e.message.contains('PERMISSION_DENIED')) {
        _publicGamesController.sink.addError(
          PermissionError(
            e.message.replaceAll('PERMISSION_DENIED:', '').trim(),
          ),
        );
      } else {
        _publicGamesController.sink.addError(Error());
      }
    } on dynamic catch (e, s) {
      LogService.instance.recordError(e, s);
      _publicGamesController.sink.addError(Error());
    }
  }
}
