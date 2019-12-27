import 'dart:async';
import 'dart:collection';

import 'package:superbingo/bloc/events/game_events.dart';
import 'package:superbingo/bloc/states/game_states.dart';
import 'package:superbingo/constants/card_deck.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/models/app_models/game.dart';
import 'package:superbingo/models/app_models/player.dart';
import 'package:superbingo/service/information_storage.dart';
import 'package:superbingo/utils/configuration_utils.dart';
import 'package:superbingo/utils/connection.dart';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class GameConfigurationBloc
    extends Bloc<GameConfigurationEvent, GameConfigurationState> {
  final Firestore db;
  String gameId;
  String gameLink;
  String gamePath;
  Player _self;

  GameConfigurationBloc(this.db) {
    _gameLinkController = BehaviorSubject<String>();
  }

  @override
  Future<void> close() async {
    await _gameLinkController?.close();
    super.close();
  }

  @override
  GameConfigurationState get initialState => WaitingGameConfigInput();

  @override
  Stream<GameConfigurationState> mapEventToState(
      GameConfigurationEvent event) async* {
    if (event is CreateGame) {
      yield* _mapCreateGameToState(event);
    } else if (event is ResetGameConfiguration) {
      yield* _mapResetGameConfigurationToState(event);
    } else if (event is DeleteConfiguredGame) {
      yield* _mapDeleteConfiguredGameToState(event);
    }
  }

  BehaviorSubject<String> _gameLinkController;
  Sink<String> get _gameLinkSink => _gameLinkController.sink;
  Stream<String> get gameLinkStream => _gameLinkController.stream;

  Stream<GameConfigurationState> _mapCreateGameToState(
      CreateGame event) async* {
    yield GameCreating();
    try {
      if (!Connection.instance.hasConnection) {
        yield GameCreationFailed(
          'Es besteht keine Internetverbindung. Bitte versuche es erneut, wenn du wieder mit Internet verbunden bist.',
        );
        yield WaitingGameConfigInput();
        return;
      }
      var game = await _createGame(
        name: event.name,
        isPublic: event.isPublic,
        maxPlayer: event.maxPlayer,
        cardAmount: event.cardAmount,
      );

      var gameDBData =
          await compute<Game, Map<String, dynamic>>(Game.toDBData, game);

      final gameDoc = await db.collection('games').add(gameDBData);
      gameId = gameDoc.documentID;
      gamePath = gameDoc.path;
      gameLink = 'superbingo://id:$gameId|name:${game.name}';
      _gameLinkSink.add(gameLink);

      game = game.copyWith(gameId: gameId);
      gameDBData =
          await compute<Game, Map<String, dynamic>>(Game.toDBData, game);

      await db.collection('games').document(gameId).updateData(gameDBData);

      InformationStorage.instance.playerId = _self.id;
      InformationStorage.instance.gameId = gameId;
      InformationStorage.instance.gameLink = gameLink;

      yield GameCreated(
        gameId: gameId,
        gameLink: gameLink,
        self: _self,
      );
    } on dynamic catch (e, s) {
      await Crashlytics.instance.recordError(e, s);
      yield GameCreationFailed(
        'Beim erstellen des Spiels ist ein Fehler aufgetreten.',
      );
      yield WaitingGameConfigInput();
    }
  }

  Stream<GameConfigurationState> _mapResetGameConfigurationToState(
      ResetGameConfiguration event) async* {
    _self = null;
    yield WaitingGameConfigInput();
  }

  Stream<GameConfigurationState> _mapDeleteConfiguredGameToState(
      DeleteConfiguredGame event) async* {
    await endGame();
    yield WaitingGameConfigInput();
  }

  Future<Game> _createGame({
    String name,
    int cardAmount,
    int maxPlayer,
    bool isPublic,
  }) async {
    final username = await getUsername();
    _self = Player.create(username, isHost: true);

    var cardStack = _generateCardStack(cardAmount);
    _self.drawCards(cardStack);

    var filledGame = Game(
      unplayedCardStack: cardStack,
      playedCardStack: Queue<GameCard>(),
      players: <Player>[
        _self,
      ],
      isPublic: isPublic,
      cardAmount: cardAmount,
      maxPlayer: maxPlayer,
      name: name,
      state: GameState.waitingForPlayer,
    );

    return filledGame;
  }

  Future<void> endGame() async {
    await db.collection('games').document(gameId).delete();
  }

  Queue<GameCard> _generateCardStack(int amount) {
    final uuid = Uuid();
    var decks = (amount / 32).truncate() - 1;
    var cardDecks = defaultCardDeck;
    for (var i = 0; i < decks; i++) {
      cardDecks += defaultCardDeck;
    }
    cardDecks.shuffle();
    cardDecks = cardDecks.map((c) => c.setId(uuid.v4())).toList();

    return Queue<GameCard>.from(cardDecks);
  }
}
