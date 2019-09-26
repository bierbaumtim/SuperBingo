import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:rxdart/rxdart.dart';
import 'package:superbingo/constants/card_deck.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/models/app_models/game.dart';
import 'package:superbingo/models/app_models/player.dart';
import 'package:superbingo/utils/stack.dart';

class GameBloc {
  Firestore db;
  StreamSubscription gameSub;
  String gameId;
  String gameLink;
  String gamePath;

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
      Game filledGame = game.copyWith(
        playedCardStack: _generateCardStack(game.cardAmount),
      );

      final gameDoc = await db.collection('games').add(filledGame.toJson());
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

  void handleNetworkDataChange(DocumentSnapshot snapshot) async {
    final game = Game.fromJson(snapshot.data);
    _playerSink.add(game.players);
    _cardController.add(game.playedCardStack.toList());
  }

  Stack<GameCard> _generateCardStack(int amount) {
    int decks = (amount / 32).truncate() - 1;
    print(decks);
    List<GameCard> cardDecks = defaultCardDeck;
    for (var i = 0; i < decks; i++) {
      cardDecks += defaultCardDeck;
    }
    return Stack.from(cardDecks..shuffle());
  }
}
