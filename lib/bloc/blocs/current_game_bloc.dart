import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:lumberdash/lumberdash.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superbingo/constants/card_deck.dart';
import 'package:superbingo/constants/enums.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/models/app_models/game.dart';
import 'package:superbingo/models/app_models/player.dart';
import 'package:superbingo/models/app_models/rules.dart';

class CurrentGameBloc {
  Firestore db;
  StreamSubscription gameSub;
  String gameId;
  String gameLink;
  String gamePath;
  int _playerId;
  Game _game;
  Player _self;

  CurrentGameBloc() {
    _playerController = BehaviorSubject<List<Player>>();
    _playedCardsController = BehaviorSubject<List<GameCard>>();
    _unplayedCardsController = BehaviorSubject<List<GameCard>>();
    _handCardController = BehaviorSubject<List<GameCard>>();
    db ??= Firestore.instance;
  }

  void dispose() {
    _playerController.close();
    _playedCardsController.close();
    _unplayedCardsController.close();
    _handCardController.close();
    gameSub.cancel();
  }

  BehaviorSubject<List<Player>> _playerController;
  Sink<List<Player>> get _playerSink => _playerController.sink;
  Stream<List<Player>> get playerStream => _playerController.stream;

  BehaviorSubject<List<GameCard>> _playedCardsController;
  Sink<List<GameCard>> get _playedCardsSink => _playedCardsController.sink;
  Stream<List<GameCard>> get playedCardsStream => _playedCardsController.stream;

  BehaviorSubject<List<GameCard>> _unplayedCardsController;
  Sink<List<GameCard>> get _unplayedCardsSink => _unplayedCardsController.sink;
  Stream<List<GameCard>> get unplayedCardsStream => _unplayedCardsController.stream;

  BehaviorSubject<List<GameCard>> _handCardController;
  Sink<List<GameCard>> get _handCardSink => _handCardController.sink;
  Stream<List<GameCard>> get handCardStream => _handCardController.stream;

  Future<void> startGame() async {
    final snapshot = await db.collection('games').document(gameId).get();
    handleNetworkDataChange(snapshot);
    gameSub = db.collection('games').document(gameId).snapshots().listen(handleNetworkDataChange);
  }

  Future<void> leaveGame() async {
    final snapshot = await db.collection('games').document(gameId).get();
    var game = Game.fromJson(snapshot.data);
    if (_self.isHost) {
      game.players.removeWhere((t) => t.id == _self.id);
      if (game.players.isNotEmpty) {
        game.players[0] = game.players[0].copyWith(isHost: true);
      } else {
        gameSub.cancel();
        await db.collection('games').document(gameId).delete();
        return;
      }
    } else {
      game.players.removeWhere((t) => t.id == _self.id);
      final unplayerdCards = game.unplayedCardStack.toList();
      game = game.copyWith(
        unplayedCardStack: Queue<GameCard>.from(_self.cards.toList() + unplayerdCards),
      );
    }
    gameSub.cancel();
    final gameDBData = await compute<Game, Map<String, dynamic>>(gameToDbData, game);
    await db.collection('games').document(gameId).updateData(gameDBData);
    _self = null;
    _playerId = null;
    gameId = null;
    gameLink = null;
    gamePath = null;
  }

  void handleNetworkDataChange(DocumentSnapshot snapshot) async {
    _game = Game.fromJson(snapshot.data);
    final player = getPlayerFromGame(_game.players, _playerId);
    _playerSink.add(_game?.players);
    _playedCardsSink.add(_game?.playedCardStack?.toList()?.reversed);
    _unplayedCardsSink.add(_game.unplayedCardStack?.toList());
    _handCardSink.add(player?.cards);
  }

  Future<String> playCard(GameCard card) async {
    // if (_game.currentPlayerId != _playerId) return 'Du bist nicht an der Reihe';
    if (!Rules.isCardAllowed(card, _game.topCard)) return 'Du darfst diese Karte nicht legen';

    _self.cards.removeWhere((c) => c == card);
    final index = _game.players.indexWhere((p) => p.id == _self.id);
    final nextPlayer = getNextPlayer(_game, _playerId);
    _game.players.replaceRange(index, index + 1, [_self]);
    var filledGame = _game.copyWith(
      playedCardStack: _game.playedCardStack..add(card),
      currentPlayerId: nextPlayer.id,
      players: _game.players,
    );

    final gameDBData = await compute<Game, Map<String, dynamic>>(gameToDbData, filledGame);

    await db.collection('games').document(gameId).updateData(gameDBData);

    return '';
  }

  Player getPlayerFromGame(List<Player> player, int playerId) {
    if (player.isEmpty) {
      logWarning('[getPlayerFromGame] Player in Game are empty. Can cause problems.');
      return null;
    } else {
      return player.firstWhere((p) => p.id == _playerId, orElse: () => null);
    }
  }

  Player getNextPlayer(Game game, int playerId) {
    var index = game?.players?.indexWhere((p) => p.id == playerId) ?? -1;
    if (index + 1 > game.players.length - 1) {
      index = 0;
    } else {
      index++;
    }
    return game?.players?.elementAt(index);
  }

  static Map<String, dynamic> gameToDbData(Game game) {
    final json = jsonEncode(game);
    return jsonDecode(json);
  }
}
