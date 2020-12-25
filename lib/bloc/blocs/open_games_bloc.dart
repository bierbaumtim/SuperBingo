import 'dart:async';

import 'package:flutter/services.dart';

import 'package:firedart/firedart.dart';
import 'package:rxdart/subjects.dart';

import '../../models/app_models/game.dart';
import '../../services/log_service.dart';

class PublicGamesBloc {
  StreamSubscription _gamesSub;

  PublicGamesBloc() {
    _publicGamesController = BehaviorSubject<List<Game>>();
    initListener();
  }

  BehaviorSubject<List<Game>> _publicGamesController;

  Sink get _publicGamesSink => _publicGamesController.sink;
  Stream<List<Game>> get publicGamesStream => _publicGamesController.stream;

  Future<void> getPublicGames() async {
    final dbGames = await Firestore.instance.collection('games').get();
    _publicGamesSink.add(null);
    _handleSnapshot(dbGames);
  }

  void initListener() {
    final dbGames = Firestore.instance.collection('games');
    _gamesSub = dbGames.stream
        .listen(_handleSnapshot); // snapshots().listen(_handleSnapshot);
  }

  void _handleSnapshot(List<Document> snapshot) {
    try {
      final games = snapshot.map<Game>((g) => Game.fromJson(g.map)).toList();
      final publicGames = games
          .where((game) =>
              game.isPublic && game.state == GameState.waitingForPlayer)
          .toList();

      _publicGamesSink.add(publicGames);
    } on PlatformException catch (e) {
      if (e.message.contains('PERMISSION_DENIED')) {
        _publicGamesSink.add(PermissionError(
            e.message.replaceAll('PERMISSION_DENIED:', '').trim()));
      } else {
        _publicGamesSink.add(Error());
      }
    } on dynamic catch (e, s) {
      LogService.instance.recordError(e, s);
      _publicGamesSink.add(Error());
    }
  }

  void dispose() {
    _publicGamesController?.close();
    _gamesSub?.cancel();
  }
}

class PermissionError extends Error {
  final String message;

  PermissionError(this.message);
}
