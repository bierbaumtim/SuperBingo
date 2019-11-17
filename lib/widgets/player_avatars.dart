import 'package:flutter/material.dart';

import 'package:superbingo/bloc/blocs/current_game_bloc.dart';
import 'package:superbingo/bloc/states/current_game_states.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superbingo/widgets/player_avatar.dart';

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
        if (state is CurrentGameLoaded) {
          if (state.game.players.isNotEmpty) {
            return Positioned(
              bottom: playerAvatarBottomPosition,
              top: 8,
              left: 8,
              right: 8,
              child: Stack(
                children: state.game.players.map((p) {
                  final index = state.game.players.indexOf(p);
                  final length = state.game.players.length;
                  final postitionCoordinates = _getPositionCoordinates(
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
        } else {
          return Container();
        }
      },
    );
  }

  Map<String, double> _getPositionCoordinates(
    int index,
    int length,
    double playerAvatarBottomPosition,
  ) {
    double top, left, right, bottom;
    switch (length) {
      case 2:
        if (index == 0) {
          left = 0;
        } else {
          right = 0;
        }
        break;
      case 3:
        if (index < 2) {
          left = 0;
        } else {
          right = 0;
        }

        if (index == 0) bottom = 0;
        break;
      case 4:
        if (index < 2) {
          left = 0;
        } else {
          right = 0;
        }

        if (index == 0 || index == 3) bottom = 0;
        break;
      case 5:
        if (index < 3) {
          left = 0;
        } else {
          right = 0;
        }

        if (index == 0) bottom = 0;
        if (index == 1 || index == 4) {
          top = (playerAvatarBottomPosition / 2) - 32;
        }
        break;
      case 6:
        if (index < 3) {
          left = 0;
        } else {
          right = 0;
        }

        if (index == 0 || index == 5) bottom = 0;
        if (index == 1 || index == 4) {
          top = (playerAvatarBottomPosition / 2) - 32;
        }
        break;
      default:
        left = 0;
        top = 0;
        right = 0;
        bottom = 0;
    }

    return {
      'top': top,
      'left': left,
      'right': right,
      'bottom': bottom,
    };
  }
}
