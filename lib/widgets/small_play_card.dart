import 'dart:math';

import 'package:flutter/material.dart';

import 'package:superbingo/models/app_models/card.dart' as cardModel;
import 'package:superbingo/widgets/card_number_color.dart';
import 'package:superbingo/widgets/inner_card_icons.dart';

import 'package:vector_math/vector_math.dart' show radians;

class SmallPlayCard extends StatelessWidget {
  final cardModel.Card card;
  final double angle;
  final double rotationAngle;
  final int index;

  const SmallPlayCard({
    Key key,
    this.card,
    this.angle,
    this.rotationAngle,
    this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardWidget = GestureDetector(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: SizedBox(
          height: 175,
          width: 100,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 24,
                bottom: 24,
                left: 32,
                right: 32,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InnerCardIcons(
                      color: card.color,
                      isSmall: true,
                    ),
                    Transform.rotate(
                      angle: radians(180),
                      child: InnerCardIcons(
                        color: card.color,
                        isSmall: true,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: CardNumberColor(
                  color: card.color,
                  number: card.number,
                  isSmall: true,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CardNumberColor(
                  color: card.color,
                  number: card.number,
                  isSmall: true,
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: CardNumberColor(
                  color: card.color,
                  number: card.number,
                  isSmall: true,
                  flip: true,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: CardNumberColor(
                  color: card.color,
                  number: card.number,
                  isSmall: true,
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
          child: cardWidget,
        ),
      );
    } else {
      return cardWidget;
    }
  }
}
