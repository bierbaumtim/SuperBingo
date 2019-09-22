import 'dart:math';

import 'package:flutter/material.dart';

import 'package:superbingo/models/app_models/card.dart' as cardModel;
import 'package:superbingo/utils/card_utils.dart';
import 'package:superbingo/widgets/card_number_color.dart';
import 'package:superbingo/widgets/inner_card_icons.dart';
import 'package:superbingo/widgets/inner_card_image.dart';

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
        elevation: (index + 1).toDouble(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: SizedBox(
          height: 175,
          width: 100,
          child: Stack(
            children: <Widget>[
              if (!isNumberCard(card.number))
                Positioned(
                  top: 10,
                  right: 14,
                  left: 14,
                  bottom: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                ),
              if (isNumberCard(card.number))
                Positioned(
                  top: 20,
                  bottom: 20,
                  left: 24,
                  right: 24,
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
              if (!isNumberCard(card.number))
                Positioned(
                  top: 20,
                  bottom: 20,
                  left: 24,
                  right: 24,
                  child: InnerCardImage(),
                ),
              Positioned(
                top: 16,
                left: 10,
                child: CardNumberColor(
                  color: card.color,
                  number: card.number,
                  isSmall: true,
                ),
              ),
              Positioned(
                top: 16,
                right: 10,
                child: CardNumberColor(
                  color: card.color,
                  number: card.number,
                  isSmall: true,
                ),
              ),
              Positioned(
                bottom: 16,
                left: 10,
                child: CardNumberColor(
                  color: card.color,
                  number: card.number,
                  isSmall: true,
                  flip: true,
                ),
              ),
              Positioned(
                bottom: 16,
                right: 10,
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
