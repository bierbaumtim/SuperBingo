import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superbingo/blocs/events/game_events.dart';
import 'package:superbingo/constants/card_deck.dart';
import 'package:superbingo/constants/enums.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/models/app_models/game.dart';
import 'package:superbingo/models/app_models/player.dart';

enum GameBlocState { empty, created, waitingForPlayer }

class GameBloc extends Bloc<GameEvent, GameState> {
  Firestore db;
  StreamSubscription gameSub;
  String gameId;
  String gameLink;
  String gamePath;
  Player _self;

  GameBloc() {
    _gameLinkController = BehaviorSubject<String>();
    _gameBlocStateController = BehaviorSubject.seeded(GameBlocState.empty);
    db ??= Firestore.instance;
  }

  @override
  void close() {
    _gameLinkController.close();
    gameSub.cancel();
    super.close();
  }

  @override
  get initialState => null;

  @override
  Stream<GameState> mapEventToState(GameEvent event) {
    // TODO: implement mapEventToState
    return null;
  }

  BehaviorSubject<String> _gameLinkController;
  Sink<String> get _gameLinkSink => _gameLinkController.sink;
  Stream<String> get gameLinkStream => _gameLinkController.stream;

  BehaviorSubject<GameBlocState> _gameBlocStateController;

  Future<bool> createGame(Game game) async {
    try {
      final username = await getUsername();
      _self = createPlayer(username, isHost: true);
      Queue<GameCard> cardStack = _generateCardStack(game.cardAmount);
      drawCards(_self, cardStack);
      _playerId = _self.id;

      Game filledGame = game.copyWith(
        unplayedCardStack: cardStack,
        players: [
          _self,
        ],
      );

      var gameDBData = await compute<Game, Map<String, dynamic>>(gameToDbData, filledGame);

      final gameDoc = await db.collection('games').add(gameDBData);
      gameId = gameDoc.documentID;
      gamePath = gameDoc.path;
      gameLink = 'superbingo://id:$gameId|name:${game.name}';
      _gameLinkSink.add(gameLink);

      filledGame = filledGame.copyWith(gameId: gameId);
      gameDBData = await compute<Game, Map<String, dynamic>>(gameToDbData, filledGame);

      await db.collection('games').document(gameId).updateData(gameDBData);

      return true;
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s);
      return false;
    }
  }

  Future<void> startGame() async {
    final snapshot = await db.collection('games').document(gameId).get();
    handleNetworkDataChange(snapshot);
    gameSub = db.collection('games').document(gameId).snapshots().listen(handleNetworkDataChange);
  }

  Future<JoiningState> joinGame(String gameId) async {
    try {
      if (gameId == null) {
        return JoiningState.dataIssue;
      }
      if (gameId.isEmpty) {
        return JoiningState.dataIssue;
      }
      this.gameId = gameId;
      final username = await getUsername();
      _self = createPlayer(username);
      final snapshot = await db.collection('games').document(gameId).get();
      final game = Game.fromJson(snapshot.data);
      if (game.players.indexWhere((p) => p.id == _self.id) >= 0) {
        return JoiningState.playerAlreadyJoined;
      }
      Queue cardStack = game.unplayedCardStack;
      drawCards(_self, cardStack);
      game.addPlayer(_self);
      Game filledGame = game.copyWith(
        unplayedCardStack: cardStack,
      );
      _playerId = _self.id;
      final gameDBData = await compute<Game, Map<String, dynamic>>(gameToDbData, filledGame);

      gameSub = db.collection('games').document(gameId).snapshots().listen(handleNetworkDataChange);
      await db.collection('games').document(gameId).updateData(gameDBData);

      return JoiningState.success;
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s);
      return JoiningState.error;
    }
  }

  Future<void> endGame() async {
    await db.collection('games').document(gameId).delete();
  }

  Queue<GameCard> _generateCardStack(int amount) {
    int decks = (amount / 32).truncate() - 1;
    List<GameCard> cardDecks = defaultCardDeck;
    for (var i = 0; i < decks; i++) {
      cardDecks += defaultCardDeck;
    }
    return Queue.from(cardDecks..shuffle());
  }

  Player createPlayer(String username, {bool isHost = false}) => Player(
        id: DateTime.now().millisecondsSinceEpoch,
        name: username,
        isHost: isHost,
      );

  void drawCards(Player player, Queue<GameCard> cards, {int amount = 6}) {
    for (var i = 0; i < amount - 1; i++) {
      player.drawCard(cards.removeFirst());
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
