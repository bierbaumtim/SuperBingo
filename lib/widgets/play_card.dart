import 'dart:math';

import 'package:flutter/material.dart';

import 'package:superbingo/constants/typedefs.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/utils/card_utils.dart';
import 'package:superbingo/widgets/card_back_custom_painter.dart';
import 'package:superbingo/widgets/card_number_color.dart';
import 'package:superbingo/widgets/inner_card_icons.dart';
import 'package:superbingo/widgets/inner_card_image.dart';

import 'package:vector_math/vector_math.dart' show radians;

class PlayCard extends StatelessWidget {
  /// [GameCard]-Object wozu die graphische Spielkarte erstellt werden soll
  final GameCard card;

  /// Konfiguration, Höhe der Spielkarte
  ///
  /// Default: 175
  final double height;

  /// Konfiguration, Breite der Spielkarte
  ///
  /// Default: 100
  final double width;
  final double angle;
  final double rotationAngle;

  /// Schatten
  ///
  /// Default: 0
  final double elevation;

  /// Konfiguration, ob die Karte aufgedeckt liegt
  ///
  /// `true`: Karte ist verdeckt
  /// `false`: Karte ist aufgedeckt
  ///
  /// Default: `true`
  final bool isFlipped;

  /// Konfiguration, ob die Karte graphisch dargestellt werden soll
  /// oder nur eine weiße Karte gezeigt werden soll
  final bool shouldPaint;

  /// Callback, wenn auf die Spielkarte gedrückt wird
  final OnCardTap onCardTap;

  const PlayCard({
    Key key,
    @required this.card,
    this.angle,
    this.rotationAngle,
    this.height = 175,
    this.width = 100,
    this.elevation = 0,
    this.isFlipped = true,
    this.shouldPaint = true,
    @required this.onCardTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget paint;
    if (shouldPaint) {
      if (isFlipped) {
        paint = _InactivePaint();
      } else {
        paint = _ActivePaint(
          card: card,
        );
      }
    } else {
      paint = Container();
    }

    final cardWidget = GestureDetector(
      onTap: () {
        onCardTap?.call(card);
      },
      child: Card(
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Colors.white,
        child: SizedBox(
          height: height,
          width: width,
          child: paint,
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

class _ActivePaint extends StatelessWidget {
  const _ActivePaint({
    Key key,
    @required this.card,
  }) : super(key: key);

  final GameCard card;

  @override
  Widget build(BuildContext context) {
    return Stack(
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
            left: 28,
            right: 28,
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
            left: 28,
            right: 28,
            child: InnerCardImage(),
          ),
        Positioned(
          top: 16,
          left: 4,
          child: CardNumberColor(
            color: card.color,
            number: card.number,
          ),
        ),
        Positioned(
          top: 16,
          right: 4,
          child: CardNumberColor(
            color: card.color,
            number: card.number,
          ),
        ),
        Positioned(
          bottom: 16,
          left: 4,
          child: CardNumberColor(
            color: card.color,
            number: card.number,
            flip: true,
          ),
        ),
        Positioned(
          bottom: 16,
          right: 4,
          child: CardNumberColor(
            color: card.color,
            number: card.number,
            flip: true,
          ),
        ),
      ],
    );
  }
}

class _InactivePaint extends StatelessWidget {
  const _InactivePaint({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: FractionalTranslation(
          translation: Offset(-.5, -.25),
          child: Transform.rotate(
            child: const CustomPaint(
              painter: CardBackPainter(),
            ),
            angle: radians(45),
          ),
        ),
      ),
    );
  }
}
