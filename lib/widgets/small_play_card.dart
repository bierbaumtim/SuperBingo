import 'dart:math';

import 'package:flutter/material.dart';

import 'package:vector_math/vector_math.dart' show radians;

import '../constants/typedefs.dart';
import '../constants/ui_constants.dart';
import '../models/app_models/card.dart';
import '../utils/card_utils.dart';
import 'card_number_color.dart';
import 'inner_card_icons.dart';
import 'inner_card_image.dart';

class SmallPlayCard extends StatelessWidget {
  final GameCard card;
  final double angle;
  final double rotationAngle;
  final int index;
  final OnCardTap onCardTap;

  const SmallPlayCard({
    Key key,
    @required this.card,
    this.angle,
    this.rotationAngle,
    this.index = 0,
    @required this.onCardTap,
  })  : assert(card != null),
        assert(onCardTap != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      constraints: const BoxConstraints(maxHeight: 175, maxWidth: 100),
      height: 175,
      width: 100,
      child: Card(
        // elevation: (index + 1).toDouble(),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Colors.white,
        child: GestureDetector(
          onTap: () => onCardTap(card),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: <Widget>[
              if (!isNumberCard(card.number))
                Positioned(
                  top: 10,
                  right: 12,
                  left: 12,
                  bottom: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
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
                      ),
                      Transform.rotate(
                        angle: radians(180),
                        child: InnerCardIcons(
                          color: card.color,
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
                top: kCardNumberColorVerticalPadding,
                left: 6,
                child: CardNumberColor(
                  color: card.color,
                  number: card.number,
                  isSmall: true,
                ),
              ),
              Positioned(
                top: kCardNumberColorVerticalPadding,
                right: 6,
                child: CardNumberColor(
                  color: card.color,
                  number: card.number,
                  isSmall: true,
                ),
              ),
              Positioned(
                bottom: kCardNumberColorVerticalPadding,
                left: 6,
                child: CardNumberColor(
                  color: card.color,
                  number: card.number,
                  isSmall: true,
                  flip: true,
                ),
              ),
              Positioned(
                bottom: kCardNumberColorVerticalPadding,
                right: 6,
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
      final rad = radians(angle);

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
