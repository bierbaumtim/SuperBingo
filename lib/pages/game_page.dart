import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superbingo/blocs/game_bloc.dart';

import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/models/app_models/player.dart';
import 'package:superbingo/widgets/card_hand.dart';
import 'package:superbingo/widgets/play_card.dart';

import 'package:vector_math/vector_math.dart' show radians;

final List<GameCard> cards = [
  GameCard(
    color: CardColor.clover,
    number: CardNumber.ace,
  ),
  GameCard(
    color: CardColor.diamond,
    number: CardNumber.king,
  ),
  GameCard(
    color: CardColor.diamond,
    number: CardNumber.nine,
  ),
  GameCard(
    color: CardColor.clover,
    number: CardNumber.eight,
  ),
  GameCard(
    color: CardColor.heart,
    number: CardNumber.six,
  ),
  GameCard(
    color: CardColor.clover,
    number: CardNumber.queen,
  ),
  GameCard(
    color: CardColor.heart,
    number: CardNumber.seven,
  ),
  GameCard(
    color: CardColor.spade,
    number: CardNumber.six,
  ),
  GameCard(
    color: CardColor.clover,
    number: CardNumber.five,
  ),
];

final List<String> player = [
  'Player1',
  'Player2',
  'Player3',
  'Player4',
  'Player5',
  'Player6',
];

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrangeAccent,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            const CardStack(),
            const CardHand(),
            const PlayerAvatars(),
          ],
        ),
      ),
    );
  }
}

class CardStack extends StatelessWidget {
  const CardStack({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameBloc = Provider.of<GameBloc>(context);

    return StreamBuilder<List<GameCard>>(
      stream: gameBloc.cardStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isNotEmpty) {
            final cards = snapshot.data;

            return Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Stack(
                  children: cards.map<Widget>((c) {
                    final rn = Random();
                    final index = cards.indexOf(c);
                    double angle = 1.0 + rn.nextInt(10);
                    double translationY, translationX;
                    if (c == cards.last) {
                      angle = radians(0);
                    } else {
                      angle = radians(angle);
                      angle = index % 2 == 0 ? angle : -angle;
                    }
                    translationY = 1.0 + rn.nextInt(5);
                    translationX = 1.0 + rn.nextInt(5);
                    if (rn.nextDouble() <= 0.5) {
                      translationX = -translationX;
                    }
                    if (rn.nextDouble() <= 0.5) {
                      translationY = -translationY;
                    }

                    return Transform(
                      child: Transform.rotate(
                        child: PlayCard(
                          height: 275,
                          width: 175,
                          card: c,
                          index: index,
                        ),
                        angle: angle,
                      ),
                      transform: Matrix4.identity()
                        ..translate(
                          translationX,
                          translationY,
                        ),
                    );
                  }).toList(),
                ),
              ),
            );
          } else {
            return Container();
          }
        } else
          return Container();
      },
    );
  }
}

class PlayerAvatars extends StatelessWidget {
  const PlayerAvatars({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final playerAvatarBottomPosition = height / 2.1;

    final gameBloc = Provider.of<GameBloc>(context);

    return StreamBuilder<List<Player>>(
      stream: gameBloc.playerStream,
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
                return Material(
                  elevation: 3,
                  child: Positioned(
                    left: left,
                    bottom: bottom,
                    right: right,
                    top: top,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CircleAvatar(
                          child: Text(
                            p.name.substring(0, 1).toUpperCase(),
                          ),
                          backgroundColor: Colors.green,
                          minRadius: 25,
                        ),
                        FractionalTranslation(
                          translation: Offset(0, -0.6),
                          child: Text(
                            p.name,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.body1.copyWith(
                                  background: Paint()..color = Colors.white,
                                  color: Colors.black,
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
