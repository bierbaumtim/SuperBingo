import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:superbingo/bloc/events/join_game_events.dart';
import 'package:superbingo/bloc/states/join_game_states.dart';
import 'package:superbingo/models/app_models/game.dart';
import 'package:superbingo/models/app_models/player.dart';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superbingo/service/information_storage.dart';

class JoinGameBloc extends Bloc<JoinGameEvent, JoinGameState> {
  Firestore db;
  String gameId;
  String gameLink;
  String gamePath;
  Player _self;

  JoinGameBloc() {
    db ??= Firestore.instance;
  }

  @override
  JoinGameState get initialState => JoiningGame();

  @override
  Stream<JoinGameState> mapEventToState(
    JoinGameEvent event,
  ) async* {
    if (event is JoinGame) {
      yield* _mapJoinGameToState(event);
    }
  }

  Stream<JoinGameState> _mapJoinGameToState(JoinGame event) async* {
    yield JoiningGame();
    gameId = event.gameId;
    if (gameId == null || gameId.isEmpty) {
      yield JoinGameFailed(
        'Dieses Spiel existiert nicht mehr oder konnte nicht gefunden werden. '
        'Bitte versuche es mit einem anderen Spiel erneut.',
      );
      yield WaitingForAction();
    } else {
      try {
        gameId = gameId;
        final username = await getUsername();
        _self = Player.create(username);
        final snapshot = await db.collection('games').document(gameId).get();
        final game = Game.fromJson(snapshot.data);
        if (game.players.indexWhere((p) => p.id == _self.id) >= 0) {
          yield JoinGameFailed(
            'Beim Verlassen des Spiels ist ein Fehler aufgetreten. '
            'Du kannst diesem Spiel daher nicht erneut beitreten.',
          );
        } else {
          Queue cardStack = game.unplayedCardStack;
          _self.drawCards(cardStack);
          game.addPlayer(_self);
          var filledGame = game.copyWith(
            unplayedCardStack: cardStack,
          );
          final gameDBData = await compute<Game, Map<String, dynamic>>(gameToDbData, filledGame);

          await db.collection('games').document(gameId).updateData(gameDBData);

          InformationStorage.instance.gameId = filledGame.gameID;
          InformationStorage.instance.playerId = _self.id;

          yield JoinedGame(
            gameId: filledGame.gameID,
            self: _self,
          );
        }
      } on dynamic catch (e, s) {
        await Crashlytics.instance.recordError(e, s);
        yield JoinGameFailed(
          'Beim Beitreten ist ein Fehler aufgetreten. Versuche es später erneut.'
        );
        yield WaitingForAction();
      }
    }
  }

  Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? '';
  }

  static Map<String, dynamic> gameToDbData(Game game) {
    final json = jsonEncode(game);
    return jsonDecode(json);
  }
}
