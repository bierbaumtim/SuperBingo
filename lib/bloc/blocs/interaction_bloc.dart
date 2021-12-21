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

  InteractionBloc(this.networkService) : super(InitialInteractionState()) {
    on<CallBingo>(_handleCallBingo);
    on<CallSuperBingo>(_handleCallSuperBingo);
  }

  Future<void> _handleCallBingo(
    CallBingo event,
    Emitter<InteractionState> emit,
  ) async {
    var game = networkService.currentGame;
    if (game == null) return;

    final self = Player.getPlayerFromList(
      game.players,
      InformationStorage.instance.playerId,
    );
    if (self != null) {
      game = game.copyWith(
        message: '${self.name} hat nur noch eine Karte!',
      );
      await networkService.updateGameData(game);
    } else {
      /// TODO: Log: eigenes Spieler-Objekt konnte nicht in der Liste gefunden werden
    }
  }

  Future<void> _handleCallSuperBingo(
    CallSuperBingo event,
    Emitter<InteractionState> emit,
  ) async {
    var game = networkService.currentGame;
    if (game == null) return;

    final self = Player.getPlayerFromList(
      game.players,
      InformationStorage.instance.playerId,
    );
    if (self != null) {
      final maxPosition = game.players
          .maxBy(
            (prev, curr) => prev.finishPosition.compareTo(curr.finishPosition),
          )!
          .finishPosition;
      final playerFinishPosition = math.max(1, maxPosition + 1);

      if (playerFinishPosition + 1 >= game.players.length) {
        game.state = GameState.gameCompleted;
        game.currentPlayerId = '';
      }

      game.updatePlayer(
        self.copyWith(finishPosition: playerFinishPosition),
      );
      game = game.copyWith(
        message: '${self.name} ist fertig !',
      );
      await networkService.updateGameData(game);
    } else {
      /// TODO: Log: eigenes Spieler-Objekt konnte nicht in der Liste gefunden werden
    }
  }
}
