import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../../constants/card_deck.dart';
import '../../models/app_models/card.dart';
import '../../models/app_models/game.dart';
import '../../models/app_models/player.dart';
import '../../service/information_storage.dart';
import '../../services/network_service.dart';
import '../../utils/configuration_utils.dart';
import '../../utils/connection.dart';
import '../events/game_events.dart';
import '../states/game_states.dart';

class GameConfigurationBloc
    extends Bloc<GameConfigurationEvent, GameConfigurationState> {
  final INetworkService networkService;

  String gameId;
  String gameLink;
  String gamePath;
  Player _self;

  GameConfigurationBloc(this.networkService) : super(WaitingGameConfigInput()) {
    _gameLinkController = BehaviorSubject<String>();
  }

  @override
  Future<void> close() async {
    await _gameLinkController?.close();
    super.close();
  }

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
    CreateGame event,
  ) async* {
    yield GameCreating();
    try {
      if (!Connection.instance.hasConnection) {
        yield const GameCreationFailed(
          'Es besteht keine Internetverbindung. Bitte versuche es erneut, wenn du wieder mit Internet verbunden bist.',
        );
        yield WaitingGameConfigInput();
        return;
      }
      var game = await _createGame(
        name: event.name,
        isPublic: event.isPublic,
        maxPlayer: event.maxPlayer,
        decksAmount: event.decksAmount,
      );

      final gameDoc = await networkService.addGame(game);
      gameId = gameDoc.id;
      gamePath = gameDoc.path;
      gameLink = 'superbingo://id:$gameId|name:${game.name}';
      _gameLinkSink.add(gameLink);

      game = game.copyWith(gameId: gameId);

      await networkService.updateGameData(
        <String, dynamic>{
          'id': gameId,
        },
        gameId,
      );

      InformationStorage.instance.playerId = _self.id;
      InformationStorage.instance.gameId = gameId;
      InformationStorage.instance.gameLink = gameLink;

      yield GameCreated(
        gameId: gameId,
        gameLink: gameLink,
        self: _self,
      );
    } on dynamic catch (e, s) {
      await FirebaseCrashlytics.instance.recordError(e, s);
      yield const GameCreationFailed(
        'Beim erstellen des Spiels ist ein Fehler aufgetreten.',
      );
      yield WaitingGameConfigInput();
    }
  }

  Stream<GameConfigurationState> _mapResetGameConfigurationToState(
    ResetGameConfiguration event,
  ) async* {
    _self = null;
    yield WaitingGameConfigInput();
  }

  Stream<GameConfigurationState> _mapDeleteConfiguredGameToState(
    DeleteConfiguredGame event,
  ) async* {
    await endGame();
    yield WaitingGameConfigInput();
  }

  Future<Game> _createGame({
    String name,
    int decksAmount,
    int maxPlayer,
    bool isPublic,
  }) async {
    final username = await getUsername();
    _self = Player.create(username, isHost: true);

    final cardStack = _generateCardStack(decksAmount);

    final filledGame = Game(
      unplayedCardStack: cardStack,
      playedCardStack: Queue<GameCard>(),
      players: <Player>[
        _self,
      ],
      isPublic: isPublic,
      cardAmount: decksAmount * defaultCardDeck.length,
      maxPlayer: maxPlayer,
      name: name,
      state: GameState.created,
    );

    filledGame.shuffleCards(times: 5);

    return filledGame;
  }

  Future<void> endGame() => networkService.deleteGame(gameId);

  Queue<GameCard> _generateCardStack(int decks) {
    final uuid = Uuid();
    var cardDecks = List<GameCard>.from(defaultCardDeck);
    for (var i = 0; i < decks - 1; i++) {
      cardDecks.addAll(defaultCardDeck);
    }
    cardDecks = cardDecks.map((c) => c.setId(uuid.v4())).toList();

    return Queue<GameCard>.from(cardDecks);
  }
}
