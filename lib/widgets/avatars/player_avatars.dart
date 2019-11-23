import 'package:flutter/material.dart';

import 'package:superbingo/bloc/blocs/current_game_bloc.dart';
import 'package:superbingo/bloc/states/current_game_states.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superbingo/models/app_models/player.dart';
import 'package:superbingo/utils/ui_utils.dart';
import 'package:superbingo/widgets/avatars/player_avatar.dart';

/// {@template playeravatars}
/// Ordnet die Avatare der Spieler anhängig von der Anzahl um den
/// Stapel der gelegten Karten und den Nachziehstapel an.
/// {@endtemplate}
class PlayerAvatars extends StatelessWidget {
  /// {@macro playeravatars}
  const PlayerAvatars({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final playerAvatarBottomPosition = (height - kToolbarHeight) / 2.1;

    final currentGameBloc = BlocProvider.of<CurrentGameBloc>(context);

    return BlocBuilder<CurrentGameBloc, CurrentGameState>(
      bloc: currentGameBloc,
      builder: (context, state) {
        var player = <Player>[];
        if (state is CurrentGameLoaded) {
          player = state.game.players;
        } else if (state is CurrentGameWaitingForPlayer) {
          player = state.game.players;
        }
        if (player.isNotEmpty) {
          return Positioned(
            bottom: playerAvatarBottomPosition,
            top: 8,
            left: 8,
            right: 8,
            child: Stack(
              children: player.map((p) {
                final index = player.indexWhere((player) => player.id == p.id);
                final length = player.length;
                final postitionCoordinates = getPositionCoordinates(
                  index,
                  length,
                  playerAvatarBottomPosition,
                );

                return PlayerAvatar(
                  postitionCoordinates: postitionCoordinates,
                  player: p,
                );
              }).toList(),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
