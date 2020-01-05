import 'dart:async';

import 'package:superbingo/bloc/events/interaction_events.dart';
import 'package:superbingo/bloc/states/interaction_states.dart';
import 'package:superbingo/models/app_models/player.dart';
import 'package:superbingo/service/information_storage.dart';
import 'package:superbingo/services/network_service.dart';

import 'package:bloc/bloc.dart';
import 'package:supercharged/supercharged.dart';

class InteractionBloc extends Bloc<InteractionEvent, InteractionState> {
  final INetworkService networkService;

  InteractionBloc(this.networkService);

  @override
  InteractionState get initialState => InitialInteractionState();

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

  Stream<InteractionState> _mapCallBingoToState(CallBingo event) async* {}

  Stream<InteractionState> _mapCallSuperBingoToState(
    CallSuperBingo event,
  ) async* {
    final game = networkService.currentGame;
    final self = Player.getPlayerFromList(
      game.players,
      InformationStorage.instance.playerId,
    );
    final maxPosition = game.players
        .maxBy(
          (prev, curr) => prev.finishPosition.compareTo(curr.finishPosition),
        )
        .finishPosition;
    game.updatePlayer(self.copyWith(finishPosition: maxPosition + 1));
    await networkService.updateGameData(game);
  }
}
