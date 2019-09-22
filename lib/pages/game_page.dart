import 'dart:math';

import 'package:flutter/material.dart';

import 'package:superbingo/models/app_models/card.dart' as cardModel;
import 'package:superbingo/widgets/card_hand.dart';
import 'package:superbingo/widgets/play_card.dart';

import 'package:vector_math/vector_math.dart' show radians;

final List<cardModel.Card> cards = [
  cardModel.Card(
    color: cardModel.CardColor.clover,
    number: cardModel.CardNumber.ace,
  ),
  cardModel.Card(
    color: cardModel.CardColor.diamond,
    number: cardModel.CardNumber.king,
  ),
  cardModel.Card(
    color: cardModel.CardColor.diamond,
    number: cardModel.CardNumber.nine,
  ),
  cardModel.Card(
    color: cardModel.CardColor.clover,
    number: cardModel.CardNumber.eight,
  ),
  cardModel.Card(
    color: cardModel.CardColor.heart,
    number: cardModel.CardNumber.six,
  ),
  cardModel.Card(
    color: cardModel.CardColor.clover,
    number: cardModel.CardNumber.queen,
  ),
  cardModel.Card(
    color: cardModel.CardColor.heart,
    number: cardModel.CardNumber.seven,
  ),
  cardModel.Card(
    color: cardModel.CardColor.spade,
    number: cardModel.CardNumber.six,
  ),
  cardModel.Card(
    color: cardModel.CardColor.clover,
    number: cardModel.CardNumber.five,
  ),
];

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
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
            ),
            CardHand(
              cards: cards,
            ),
          ],
        ),
      ),
    );
  }
}
