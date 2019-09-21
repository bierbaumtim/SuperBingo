import 'dart:math';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';

import 'package:superbingo/models/app_models/card.dart' as cardModel;
import 'package:superbingo/pages/game_page.dart';
import 'package:superbingo/utils/card_utils.dart';
import 'package:vector_math/vector_math.dart' show radians;

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Text(
                'SuperBingo',
                style: TextStyle(
                  fontSize: 45,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: 75,
              left: 0,
              right: 0,
              child: Center(
                child: RaisedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => GamePage()),
                    );
                  },
                  child: const Text('Start game'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 36,
                  ),
                  textColor: Colors.white,
                  color: Colors.orange,
                  elevation: 6.0,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: PlayCard(),
            )
          ],
        ),
      ),
    );
  }
}

class PlayCard extends StatelessWidget {
  final cardModel.Card card;
  final double height;
  final double width;
  final double angle;
  final double rotationAngle;
  final int index;
  final bool isSmall;

  const PlayCard({
    Key key,
    this.card,
    this.angle,
    this.index,
    this.rotationAngle,
    this.isSmall,
    this.height = 175,
    this.width = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = GestureDetector(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: SizedBox(
          height: height,
          width: width,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 24,
                bottom: 24,
                left: 32,
                right: 32,
                child: Container(
                  // color: Colors.green,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InnerCardIcons(
                        color: cardModel.CardColor.clover,
                      ),
                      Transform.rotate(
                        angle: radians(180),
                        child: InnerCardIcons(
                          color: cardModel.CardColor.clover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: CardNumberColor(
                  color: cardModel.CardColor.clover,
                  number: cardModel.CardNumber.eight,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CardNumberColor(
                  color: cardModel.CardColor.heart,
                  number: cardModel.CardNumber.eight,
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: CardNumberColor(
                  color: cardModel.CardColor.diamond,
                  number: cardModel.CardNumber.eight,
                  flip: true,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: CardNumberColor(
                  color: cardModel.CardColor.spade,
                  number: cardModel.CardNumber.eight,
                  flip: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (angle != null && rotationAngle != null) {
      final double rad = radians(angle);
      return Transform(
        transform: Matrix4.identity()
          ..translate(
            100 * cos(rad),
            (100 * sin(rad)) + 25,
          ),
        child: Transform.rotate(
          angle: radians(rotationAngle),
          child: card,
        ),
      );
    } else {
      return card;
    }
  }
}

class CardNumberColor extends StatelessWidget {
  const CardNumberColor({
    Key key,
    this.color,
    this.number,
    this.flip = false,
  }) : super(key: key);

  final cardModel.CardColor color;
  final cardModel.CardNumber number;
  final bool flip;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: radians(flip ? 180 : 0),
      child: Column(
        children: <Widget>[
          if (!flip) ...[
            Text(
              getTextByCardNumber(number),
              style: TextStyle(
                fontSize: 18,
                color: getColorByCardColor(color),
              ),
            ),
            SizedBox(height: 4),
          ],
          Icon(
            getIconByCardColor(color),
            color: getColorByCardColor(color),
          ),
          if (flip) ...[
            SizedBox(height: 4),
            Text(
              getTextByCardNumber(number),
              style: TextStyle(
                fontSize: 18,
                color: getColorByCardColor(color),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class InnerCardIcons extends StatelessWidget {
  final cardModel.CardColor color;

  const InnerCardIcons({
    Key key,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(
                getIconByCardColor(color),
                color: getColorByCardColor(color),
                size: 36,
              ),
              Icon(
                getIconByCardColor(color),
                color: getColorByCardColor(color),
                size: 36,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                getIconByCardColor(color),
                color: getColorByCardColor(color),
                size: 36,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(
                getIconByCardColor(color),
                color: getColorByCardColor(color),
                size: 36,
              ),
              Icon(
                getIconByCardColor(color),
                color: getColorByCardColor(color),
                size: 36,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
