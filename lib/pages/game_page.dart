import 'dart:math';

import 'package:flutter/material.dart';

import 'package:superbingo/pages/start.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<int> cards = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

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
                    var angle = (pi / 4) / cards.length;
                    final rn = Random();
                    angle += rn.nextDouble() / (4 * pi);

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
            Align(
              alignment: Alignment.bottomCenter,
              child: Stack(
                children: cards.map<Widget>((c) {
                  final index = cards.indexOf(c);
                  final middleToRightAngle = (pi / 2) / cards.length;
                  final leftToMiddleAngle = -((pi / 2) / cards.length);
                  double angle = 0;
                  if (index < cards.length / 2) {
                    angle = leftToMiddleAngle * index;
                  } else if (index == (cards.length / 2).floor()) {
                    angle = pi / 4;
                  } else if (index > cards.length / 2) {
                    angle = middleToRightAngle * index;
                  }

                  return Transform(
                    child: PlayCard(),
                    transform: Matrix4.rotationZ(middleToRightAngle * index),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
