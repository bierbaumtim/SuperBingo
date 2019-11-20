import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:lumberdash/lumberdash.dart';

import 'package:superbingo/models/app_models/game.dart';

import 'package:rxdart/subjects.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PublicGamesBloc {
  StreamSubscription _gamesSub;

  PublicGamesBloc() {
    _publicGamesController = BehaviorSubject<List<Game>>();
    initListener();
  }

  BehaviorSubject<List<Game>> _publicGamesController;

  Sink get _publicGamesSink => _publicGamesController.sink;
  Stream get publicGamesStream => _publicGamesController.stream;

  Future<void> getPublicGames() async {
    final dbGames = Firestore.instance.collection('games');
    _publicGamesSink.add(null);
    try {
      final docs = (await dbGames.getDocuments()).documents;
      final games = docs.map<Game>((g) => Game.fromJson(g.data)).toList();
      var publicGames = <Game>[];
      for (var game in games) {
        if (game.isPublic == true && game.state == GameState.waitingForPlayer) {
          publicGames.add(game);
        }
      }
      _publicGamesSink.add(publicGames);
    } on PlatformException catch (e) {
      if (e.message.contains('PERMISSION_DENIED')) {
        _publicGamesSink.add(PermissionError(e.message.replaceAll('PERMISSION_DENIED:', '').trim()));
      } else {
        _publicGamesSink.add(Error());
      }
    } on dynamic catch (e, s) {
      Crashlytics.instance.recordError(e, s);
      logError(e, stacktrace: s);
    }
  }

  void initListener() {
    final dbGames = Firestore.instance.collection('games');
    _gamesSub = dbGames.snapshots().listen(_handleSnapshot);
  }

  void _handleSnapshot(QuerySnapshot snapshot) {
    try {
      final docs = snapshot.documents;
      final games = docs.map<Game>((g) => Game.fromJson(g.data)).toList();
      var publicGames = <Game>[];
      for (var game in games) {
        if (game.isPublic == true && game.state == GameState.waitingForPlayer) {
          publicGames.add(game);
        }
      }
      _publicGamesSink.add(publicGames);
    } on PlatformException catch (e) {
      if (e.message.contains('PERMISSION_DENIED')) {
        _publicGamesSink.add(PermissionError(e.message.replaceAll('PERMISSION_DENIED:', '').trim()));
      } else {
        _publicGamesSink.add(Error());
      }
    } on dynamic catch (e, s) {
      Crashlytics.instance.recordError(e, s);
      logError(e, stacktrace: s);
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