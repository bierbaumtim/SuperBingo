import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superbingo/constants/card_deck.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/models/app_models/game.dart';
import 'package:superbingo/models/app_models/player.dart';
import 'package:superbingo/models/app_models/rules.dart';
import 'package:superbingo/utils/stack.dart';

class GameBloc {
  Firestore db;
  StreamSubscription gameSub;
  String gameId;
  String gameLink;
  String gamePath;
  int _playerId;
  Game _game;
  Player _self;

  GameBloc() {
    _playerController = BehaviorSubject<List<Player>>();
    _cardController = BehaviorSubject<List<GameCard>>();
    _handCardController = BehaviorSubject<List<GameCard>>();
    _gameLinkController = BehaviorSubject<String>();
    db ??= Firestore.instance;
  }

  void dispose() {
    _playerController.close();
    _cardController.close();
    _handCardController.close();
    _gameLinkController.close();
    gameSub.cancel();
  }

  BehaviorSubject<List<Player>> _playerController;
  Sink<List<Player>> get _playerSink => _playerController.sink;
  Stream<List<Player>> get playerStream => _playerController.stream;

  BehaviorSubject<List<GameCard>> _cardController;
  Sink<List<GameCard>> get _cardSink => _cardController.sink;
  Stream<List<GameCard>> get cardStream => _cardController.stream;

  BehaviorSubject<List<GameCard>> _handCardController;
  Sink<List<GameCard>> get _handCardSink => _handCardController.sink;
  Stream<List<GameCard>> get handCardStream => _handCardController.stream;

  BehaviorSubject<String> _gameLinkController;
  Sink<String> get _gameLinkSink => _gameLinkController.sink;
  Stream<String> get gameLinkStream => _gameLinkController.stream;

  Future<bool> createGame(Game game) async {
    try {
      final username = await getUsername();
      _self = createPlayer(username, isHost: true);
      Stack<GameCard> cardStack = _generateCardStack(game.cardAmount);
      drawCards(_self, cardStack);
      _playerId = _self.id;

      Game filledGame = game.copyWith(
        unplayedCardStack: cardStack,
        players: [
          _self,
        ],
      );

      final gameDBData = await compute<Game, Map<String, dynamic>>(gameToDbData, filledGame);

      final gameDoc = await db.collection('games').add(gameDBData);
      gameId = gameDoc.documentID;
      gamePath = gameDoc.path;
      gameLink = 'superbingo://id:$gameId|name:${game.name}';
      _gameLinkSink.add(gameLink);
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

  Future<bool> joinGame(String gameId) async {
    try {
      this.gameId = gameId;
      final username = await getUsername();
      _self = createPlayer(username);
      final snapshot = await db.collection('games').document(gameId).get();
      final game = Game.fromJson(snapshot.data);
      Stack cardStack = game.unplayedCardStack;
      drawCards(_self, cardStack);
      game.addPlayer(_self);
      Game filledGame = game.copyWith(
        // players: game.players..add(_self),
        unplayedCardStack: cardStack,
      );
      _playerId = _self.id;
      final gameDBData = await compute<Game, Map<String, dynamic>>(gameToDbData, filledGame);

      gameSub = db.collection('games').document(gameId).snapshots().listen(handleNetworkDataChange);
      await db.collection('games').document(gameId).updateData(gameDBData);

      return true;
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s);
      return false;
    }
  }

  Future<void> endGame() async {
    await db.collection('games').document(gameId).delete();
  }

  void handleNetworkDataChange(DocumentSnapshot snapshot) async {
    _game = Game.fromJson(snapshot.data);
    final player = getPlayerFromGame(_game.players, _playerId);
    _playerSink.add(_game?.players);
    _cardSink.add(_game?.playedCardStack?.toList());
    _handCardSink.add(player?.cards);
  }

  Stack<GameCard> _generateCardStack(int amount) {
    int decks = (amount / 32).truncate() - 1;
    List<GameCard> cardDecks = defaultCardDeck;
    for (var i = 0; i < decks; i++) {
      cardDecks += defaultCardDeck;
    }
    return Stack.from(cardDecks..shuffle());
  }

  Player createPlayer(String username, {bool isHost = false}) => Player(
        id: DateTime.now().millisecondsSinceEpoch,
        name: username,
        isHost: isHost,
      );

  void drawCards(Player player, Stack<GameCard> cards, {int amount = 6}) {
    for (var i = 0; i < amount - 1; i++) {
      player.drawCard(cards.remove());
    }
  }

  Future<String> playCard(GameCard card) async {
    if (_game.currentPlayerId != _playerId) return 'Du bist nicht an der Reihe';
    if (!Rules.isCardAllowed(card, _game.topCard)) return 'Du darfst diese Karte nicht legen';

    _self.cards.remove(card);
    final nextPlayer = getNextPlayer(_game, _playerId);
    Game filledGame = _game.copyWith(
      playedCardStack: _game.playedCardStack..add(card),
      currentPlayerId: nextPlayer.id,
    );

    final gameDBData = await compute<Game, Map<String, dynamic>>(gameToDbData, filledGame);

    await db.collection('games').document(gameId).updateData(gameDBData);

    return '';
  }

  Player getPlayerFromGame(List<Player> player, int playerId) {
    if (player.isEmpty) {
      // TODO Logging hinzufügen
      return null;
    } else {
      return player.firstWhere((p) => p.id == _playerId, orElse: () => null);
    }
  }

  Player getNextPlayer(Game game, int playerId) {
    int index = game?.players?.indexWhere((p) => p.id == playerId) ?? -1;
    if (index + 1 > game.players.length - 1) {
      index = 0;
    } else {
      index++;
    }
    return game?.players?.elementAt(index);
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
