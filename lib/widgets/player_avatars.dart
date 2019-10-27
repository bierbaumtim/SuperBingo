import 'package:flutter/material.dart';
import 'package:superbingo/blocs/current_game_bloc.dart';

import 'package:superbingo/models/app_models/player.dart';

import 'package:provider/provider.dart';

class PlayerAvatars extends StatelessWidget {
  const PlayerAvatars({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final playerAvatarBottomPosition = (height - kToolbarHeight) / 2.1;

    final theme = Theme.of(context);

    final currentGameBloc = Provider.of<CurrentGameBloc>(context);

    return StreamBuilder<List<Player>>(
      stream: currentGameBloc.playerStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.isNotEmpty) {
          return Positioned(
            bottom: playerAvatarBottomPosition,
            top: 8,
            left: 8,
            right: 8,
            child: Stack(
              children: snapshot.data.map((p) {
                final index = snapshot.data.indexOf(p);
                final length = snapshot.data.length;
                double top, left, right, bottom;

                switch (length) {
                  case 2:
                    if (index == 0)
                      left = 0;
                    else
                      right = 0;
                    break;
                  case 3:
                    if (index < 2)
                      left = 0;
                    else
                      right = 0;

                    if (index == 0) bottom = 0;
                    break;
                  case 4:
                    if (index < 2)
                      left = 0;
                    else
                      right = 0;

                    if (index == 0 || index == 3) bottom = 0;
                    break;
                  case 5:
                    if (index < 3)
                      left = 0;
                    else
                      right = 0;

                    if (index == 0) bottom = 0;
                    if (index == 1 || index == 4) top = (playerAvatarBottomPosition / 2) - 32;
                    break;
                  case 6:
                    if (index < 3)
                      left = 0;
                    else
                      right = 0;

                    if (index == 0 || index == 5) bottom = 0;
                    if (index == 1 || index == 4) top = (playerAvatarBottomPosition / 2) - 32;
                    break;
                  default:
                }
                return Positioned(
                  left: left,
                  bottom: bottom,
                  right: right,
                  top: top,
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
                              p.name.substring(0, 1).toUpperCase(),
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
                              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
                              color: Colors.white,
                              child: Text(
                                p.name,
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
