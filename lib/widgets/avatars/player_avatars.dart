import 'package:flutter/material.dart';

import 'package:supercharged/supercharged.dart';

import '../../models/app_models/player.dart';
import '../../utils/ui_utils.dart';
import 'player_avatar.dart';

/// {@template playeravatars}
/// Ordnet die Avatare der Spieler anhängig von der Anzahl um den
/// Stapel der gelegten Karten und den Nachziehstapel an.
/// {@endtemplate}
class PlayerAvatars extends StatelessWidget {
  /// {@macro playeravatars}
  const PlayerAvatars({
    Key key,
    @required this.player,
    @required this.currentPlayerUid,
  }) : super(key: key);

  final List<Player> player;
  final String currentPlayerUid;

  @override
  Widget build(BuildContext context) {
    if (player.isNotEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: player.mapIndexed((p, index) {
            final postitionCoordinates = getPositionCoordinates(
              index,
              player.length,
              constraints,
            );

            return PlayerAvatar(
              positionCoordinates: postitionCoordinates,
              player: p,
              isCurrentPlayer: p.id == currentPlayerUid,
            );
          }).toList(),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
