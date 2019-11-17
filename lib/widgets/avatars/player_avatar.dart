import 'package:flutter/material.dart';
import 'package:superbingo/models/app_models/player.dart';

class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    Key key,
    @required this.postitionCoordinates,
    @required this.player,
  }) : super(key: key);

  final Map<String, double> postitionCoordinates;
  final Player player;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      left: postitionCoordinates['left'],
      bottom: postitionCoordinates['bottom'],
      right: postitionCoordinates['right'],
      top: postitionCoordinates['top'],
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 52,
          maxHeight: 70,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Material(
              elevation: 12,
              color: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: CircleAvatar(
                child: Text(
                  player.name.substring(0, 1).toUpperCase(),
                  style: theme.textTheme.body1.copyWith(fontSize: 17),
                ),
                backgroundColor: Colors.green,
                minRadius: 25,
              ),
            ),
            FractionalTranslation(
              translation: Offset(0, -0.6),
              child: Material(
                elevation: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
                  color: Colors.white,
                  child: Text(
                    player.name,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: theme.textTheme.body1.copyWith(
                      color: Colors.black,
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
}
