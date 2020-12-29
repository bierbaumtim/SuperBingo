import 'package:flutter/material.dart';

import '../../models/app_models/player.dart';
import '../../models/ui_models/player_avatar_coordinates.dart';

/// {@template playeravatar}
/// Avatarähnliches Widget mit großem Anfangsbuchstaben des Namen des Spielers in der Mitte und der Anzahl der Karten des Spielers.
/// {@endtemplate}

class PlayerAvatar extends StatelessWidget {
  /// {@macro playeravatar}
  const PlayerAvatar({
    Key key,
    @required this.positionCoordinates,
    @required this.player,
    this.isCurrentPlayer = false,
  }) : super(key: key);

  /// Spieler zu dem der Avatar dargestellt werden soll
  final Player player;

  /// Position des Avatars
  final PlayerAvatarCoordinates positionCoordinates;

  final bool isCurrentPlayer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget child = SizedBox(
      width: 52,
      child: Stack(
        children: <Widget>[
          if (isCurrentPlayer)
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 50,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.greenAccent[700],
                        blurRadius: 2,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.greenAccent[400],
                        blurRadius: 4,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.greenAccent[100],
                        blurRadius: 8,
                        spreadRadius: 3,
                      ),
                      const BoxShadow(
                        color: Colors.greenAccent,
                        blurRadius: 12,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Column(
            children: <Widget>[
              SizedBox(
                width: 50,
                height: 50,
                child: Material(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.green,
                    minRadius: 20,
                    maxRadius: 20,
                    child: Text(
                      _getPlayerFirstLetter(player.name),
                      style: theme.textTheme.bodyText2.copyWith(fontSize: 17),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                player?.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: theme.textTheme.bodyText2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: FractionalTranslation(
              translation: const Offset(.175, -.175),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.red,
                ),
                padding: const EdgeInsets.all(3),
                child: Text(
                  '${player.cards.length}',
                  // '30',
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (positionCoordinates.horizontalTranslation != 0 ||
        positionCoordinates.verticalTranslation != 0) {
      child = FractionalTranslation(
        translation: Offset(
          positionCoordinates.horizontalTranslation,
          positionCoordinates.verticalTranslation,
        ),
        child: child,
      );
    }

    return Positioned(
      left: positionCoordinates.left,
      bottom: positionCoordinates.bottom,
      right: positionCoordinates.right,
      top: positionCoordinates.top,
      child: child,
    );
  }

  /// Gibt des ersten Buchstaben des Spielernames als Großbuchstaben zurück
  String _getPlayerFirstLetter(String name) {
    if (name.isEmpty) {
      return 'S';
    } else {
      return name.substring(0, 1).toUpperCase();
    }
  }
}
