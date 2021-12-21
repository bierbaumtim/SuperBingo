import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../../constants/card_deck.dart';
import '../../models/app_models/card.dart';
import '../../models/app_models/game.dart';
import '../../models/app_models/player.dart';
import '../../services/information_storage.dart';
import '../../services/log_service.dart';
import '../../services/network_service/network_service_interface.dart';
import '../../utils/configuration_utils.dart';
import '../../utils/connection.dart';
import '../events/game_events.dart';
import '../states/game_states.dart';

class GameConfigurationBloc
    extends Bloc<GameConfigurationEvent, GameConfigurationState> {
  final INetworkService networkService;

  late String _gameId;
  late String _gameLink;
  Player? _self;

  GameConfigurationBloc(this.networkService) : super(WaitingGameConfigInput()) {
    _gameLinkController = BehaviorSubject<String>();
    _gameId = '';
    _gameLink = '';

    on<CreateGame>(_handleCreateGame);
    on<ResetGameConfiguration>(_handleResetGameConfiguration);
    on<DeleteConfiguredGame>(_handleDeleteConfiguredGame);
  }

  @override
  Future<void> close() async {
    await _gameLinkController.close();
    super.close();
  }

  late BehaviorSubject<String> _gameLinkController;
  Sink<String> get _gameLinkSink => _gameLinkController.sink;
  Stream<String> get gameLinkStream => _gameLinkController.stream;

  Future<void> _handleCreateGame(
    CreateGame event,
    Emitter<GameConfigurationState> emit,
  ) async {
    emit(GameCreating());
    try {
      if (!Connection.instance.hasConnection) {
        emit(
          const GameCreationFailed(
            'Es besteht keine Internetverbindung. Bitte versuche es erneut, wenn du wieder mit dem Internet verbunden bist.',
          ),
        );
        emit(WaitingGameConfigInput());
        return;
      }
      var game = await _createGame(
        name: event.name,
        isPublic: event.isPublic,
        maxPlayer: event.maxPlayer,
        decksAmount: event.decksAmount,
      );

      final gameDoc = await networkService.addGame(game);
      game = game.copyWith(gameId: gameDoc.id);
      _gameId = gameDoc.id;
      _gameLink = game.link;
      _gameLinkSink.add(_gameLink);

      await networkService.updateGameData(
        <String, dynamic>{
          'id': _gameId,
        },
        _gameId,
      );

      InformationStorage.instance.playerId = _self!.id;
      InformationStorage.instance.gameId = _gameId;
      InformationStorage.instance.gameLink = _gameLink;

      emit(
        GameCreated(gameId: _gameId, gameLink: _gameLink, self: _self!),
      );
    } on Object catch (e, s) {
      await LogService.instance.recordError(e, s);
      emit(
        const GameCreationFailed(
          'Beim erstellen des Spiels ist ein Fehler aufgetreten.',
        ),
      );
      emit(WaitingGameConfigInput());
    }
  }

  void _handleResetGameConfiguration(
    ResetGameConfiguration event,
    Emitter<GameConfigurationState> emit,
  ) {
    _self = null;
    emit(WaitingGameConfigInput());
  }

  Future<void> _handleDeleteConfiguredGame(
    DeleteConfiguredGame event,
    Emitter<GameConfigurationState> emit,
  ) async {
    await endGame();
    emit(WaitingGameConfigInput());
  }

  Future<Game> _createGame({
    required String name,
    int decksAmount = 1,
    int maxPlayer = 6,
    bool isPublic = true,
  }) async {
    final username = await getUsername();
    _self = Player.create(username, isHost: true);

    final cardStack = _generateCardStack(decksAmount);

    final filledGame = Game(
      gameID: 'default_id_created_not_updated',
      unplayedCardStack: cardStack,
      playedCardStack: Queue<GameCard>(),
      players: <Player>[
        _self!,
      ],
      playerOrder: [
        _self!.id,
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

  Future<void> endGame() => networkService.deleteGame(_gameId);

  Queue<GameCard> _generateCardStack(int decks) {
    const uuid = Uuid();
    var cardDecks = List<GameCard>.from(defaultCardDeck);
    for (var i = 0; i < decks - 1; i++) {
      cardDecks.addAll(defaultCardDeck);
    }
    cardDecks = cardDecks.map((c) => c.setId(uuid.v4())).toList();

    return Queue<GameCard>.from(cardDecks);
  }
}
