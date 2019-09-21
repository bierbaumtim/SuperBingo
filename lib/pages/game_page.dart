import 'dart:math';

import 'package:flutter/material.dart';

import 'package:superbingo/pages/start.dart';
import 'package:superbingo/utils/list_utils.dart';
import 'package:vector_math/vector_math.dart' show radians;

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<int> cards = [
    0,
    1,
    2,
    3,
    4,
    5,
  ];
  // 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Stack(
                  children: cards.map<Widget>((c) {
                    final index = cards.indexOf(c);
                    double angle = 1.0 + Random().nextInt(10);
                    angle = radians(angle);

                    return Transform.rotate(
                      child: PlayCard(
                        height: 275,
                        width: 175,
                      ),
                      angle: index % 2 == 0 ? angle : -angle,
                    );
                  }).toList(),
                ),
              ),
            ),
            CardHand(),
          ],
        ),
      ),
    );
  }
}

class CardHand extends StatelessWidget {
  CardHand({Key key}) : super(key: key);

  List<int> cards = [
    0,
    1,
    2,
    3,
    4,
    5,
  ];
  // 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Stack(
        alignment: Alignment.center,
        children: cards.map<Widget>((c) {
          final index = cards.indexOf(c);

          double angle = 160 / cards.length;
          double rotationAngle;
          print(angle);
          if (angle >= 50) angle = 20;
          final middle = getMiddleIndex(cards);

          if (index >= middle) {
            angle = -90 - (angle * (middle - index));
            rotationAngle = 270 + angle;
          } else if (index <= middle) {
            angle = -90 - (angle * (middle - index));
            rotationAngle = 270 + angle;
          } else {
            angle = -90;
            rotationAngle = 0;
          }

          return PlayCard(
            angle: angle,
            index: index,
            rotationAngle: rotationAngle,
          );
        }).toList(),
      ),
    );
  }
}
