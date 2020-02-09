import 'package:flutter/material.dart';

import '../../models/app_models/player.dart';

/// {@template playeravatar}
/// Avatarähnliches Widget mit großem Anfangsbuchstaben des Namen des Spielers in der Mitte und der Anzahl der Karten des Spielers.
/// {@endtemplate}

class PlayerAvatar extends StatelessWidget {
  /// {@macro playeravatar}
  const PlayerAvatar({
    Key key,
    @required this.postitionCoordinates,
    @required this.player,
    this.isCurrentPlayer = false,
  }) : super(key: key);

  /// Spieler zu dem der Avatar dargestellt werden soll
  final Player player;

  /// Position des Avatars
  final Map<String, double> postitionCoordinates;

  final bool isCurrentPlayer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      left: postitionCoordinates['left'],
      bottom: postitionCoordinates['bottom'],
      right: postitionCoordinates['right'],
      top: postitionCoordinates['top'],
      child: SizedBox(
        width: 52,
        height: 60,
        child: Stack(
          fit: StackFit.expand,
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
                        BoxShadow(
                          color: Colors.greenAccent,
                          blurRadius: 12,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
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
            ),
            Positioned(
              top: 0,
              right: 0,
              child: FractionalTranslation(
                translation: const Offset(.175, -.175),
                child: Container(
                  width: 18,
                  height: 18,
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
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.black,
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 2.5, horizontal: 6),
                child: ClipRRect(
                  child: Material(
                    elevation: 14,
                    color: Colors.black,
                    child: Text(
                      player?.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      style: theme.textTheme.bodyText2.copyWith(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
