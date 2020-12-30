import 'dart:async';
import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:supercharged/supercharged.dart';

import '../../models/app_models/game.dart';
import '../../models/app_models/player.dart';
import '../../services/information_storage.dart';
import '../../services/network_service/network_service_interface.dart';
import '../events/interaction_events.dart';
import '../states/interaction_states.dart';

class InteractionBloc extends Bloc<InteractionEvent, InteractionState> {
  final INetworkService networkService;

  InteractionBloc(this.networkService) : super(InitialInteractionState());

  @override
  Stream<InteractionState> mapEventToState(
    InteractionEvent event,
  ) async* {
    if (event is CallBingo) {
      yield* _mapCallBingoToState(event);
    } else if (event is CallSuperBingo) {
      yield* _mapCallSuperBingoToState(event);
    }
  }

  Stream<InteractionState> _mapCallBingoToState(CallBingo event) async* {
    var game = networkService.currentGame;
    final self = Player.getPlayerFromList(
      game.players,
      InformationStorage.instance.playerId,
    );
    game = game.copyWith(
      message: '${self.name} hat nur noch eine Karte!',
    );
    await networkService.updateGameData(game);
  }

  Stream<InteractionState> _mapCallSuperBingoToState(
    CallSuperBingo event,
  ) async* {
    var game = networkService.currentGame;
    final self = Player.getPlayerFromList(
      game.players,
      InformationStorage.instance.playerId,
    );
    final maxPosition = game.players
        .maxBy(
          (prev, curr) => prev.finishPosition.compareTo(curr.finishPosition),
        )
        .finishPosition;
    final playerFinishPosition = math.min(1, maxPosition + 1);

    if (playerFinishPosition + 1 >= game.players.length) {
      game.state = GameState.gameCompleted;
    }

    game.updatePlayer(self.copyWith(finishPosition: playerFinishPosition));
    game = game.copyWith(
      message: '${self.name} ist fertig !',
    );
    await networkService.updateGameData(game);
  }
}
