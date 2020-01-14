import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../models/app_models/game.dart';
import '../../models/app_models/player.dart';
import '../../service/information_storage.dart';
import '../../services/network_service.dart';
import '../../utils/configuration_utils.dart';
import '../events/join_game_events.dart';
import '../states/join_game_states.dart';


class JoinGameBloc extends Bloc<JoinGameEvent, JoinGameState> {
  final INetworkService networkService;
  String gameId;
  String gameLink;
  String gamePath;
  Player _self;

  JoinGameBloc(this.networkService);

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
        final username = await getUsername();
        _self = Player.create(username);
        final snapshot =
            await networkService.db.collection('games').document(gameId).get();
        final game = Game.fromJson(snapshot.data);
        if (game.players.length + 1 > game.maxPlayer) {
          yield JoinGameFailed(
            'Die maximale Spieleranzahl für dieses Spiel ist erreicht. '
            'Du kannst diesem Spiel daher nicht mehr beitreten.',
          );
        } else if (game.players.indexWhere((p) => p.id == _self.id) >= 0) {
          yield JoinGameFailed(
            'Beim Verlassen des Spiels ist ein Fehler aufgetreten. '
            'Du kannst diesem Spiel daher nicht erneut beitreten.',
          );
        } else {
          final cardStack = game.unplayedCardStack;
          _self.drawCards(cardStack);
          game.addPlayer(_self);
          var filledGame = game.copyWith(
            unplayedCardStack: cardStack,
          );

          await networkService.updateGameData(filledGame);

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
          'Beim Beitreten ist ein Fehler aufgetreten. Versuche es später erneut.',
        );
        yield WaitingForAction();
      }
    }
  }
}
