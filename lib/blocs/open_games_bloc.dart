import 'package:flutter/services.dart';

import 'package:rxdart/subjects.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PublicGamesBloc {
  PublicGamesBloc() {
    _publicGamesController = BehaviorSubject<List<DocumentSnapshot>>();
  }

  BehaviorSubject<List<DocumentSnapshot>> _publicGamesController;

  Sink get _publicGamesSink => _publicGamesController.sink;
  Stream get publicGamesStream => _publicGamesController.stream;

  Future<void> getPublicGames() async {
    final games = Firestore.instance.collection('games');
    try {
      final docs = (await games.getDocuments()).documents;
      List<DocumentSnapshot> publicGames = [];
      for (var game in docs) {
        // if (game.data['public'] == true) {
        //   publicGames.add(game);
        // }
        publicGames.add(game);
      }
      _publicGamesSink.add(publicGames);
    } on PlatformException catch (e) {
      if (e.message.contains('PERMISSION_DENIED')) {
        _publicGamesSink.add(PermissionError(e.message.replaceAll('PERMISSION_DENIED:', '').trim()));
      } else {
        _publicGamesSink.add(Error());
      }
    }
  }

  void dispose() {
    _publicGamesController.close();
  }
}

class PermissionError extends Error {
  final String message;

  PermissionError(this.message);
}
