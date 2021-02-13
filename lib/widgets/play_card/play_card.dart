import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:vector_math/vector_math.dart' show radians;

import '../../constants/typedefs.dart';
import '../../constants/ui_constants.dart';
import '../../models/app_models/card.dart';
import '../../utils/card_utils.dart';
import 'card_back_custom_painter.dart';
import 'card_number_color.dart';
import 'inner_card_icons.dart';
import 'inner_card_image.dart';

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

  ///
  final double angle;

  ///
  final double rotationAngle;

  ///
  final double rotationYOffset;

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

  /// Konfiguration, ob diese Karte gelegt werden darf.
  /// Steuert, ob ein entsprechendes Overlay über der Karte angezeigt wird
  /// und ob ein Tap, entsprechend behandelt oder irgnoriert wird.
  final bool canDraw;

  const PlayCard({
    Key key,
    @required this.card,
    this.angle,
    this.rotationAngle,
    this.rotationYOffset,
    this.height = 175,
    this.width = 100,
    this.elevation = 0,
    this.isFlipped = true,
    this.shouldPaint = true,
    this.canDraw = true,
    @required this.onCardTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget paint;
    if (shouldPaint) {
      if (isFlipped) {
        paint = const _InactivePaint();
      } else {
        paint = _ActivePaint(
          card: card,
          canDraw: canDraw,
        );
      }
    } else {
      paint = const SizedBox();
    }

    final child = GestureDetector(
      onTap: () {
        if (canDraw) {
          onCardTap?.call(card);
        }
      },
      child: Card(
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
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
            100 * math.cos(rad),
            (100 * math.sin(rad)) + (rotationYOffset ?? 25),
          ),
        child: Transform.rotate(
          angle: radians(rotationAngle),
          child: child,
        ),
      );
    } else {
      return child;
    }
  }
}

class _ActivePaint extends StatelessWidget {
  const _ActivePaint({
    Key key,
    @required this.card,
    this.canDraw = true,
  }) : super(key: key);

  final GameCard card;
  final bool canDraw;

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                border: Border.all(),
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
          top: kCardNumberColorVerticalPadding,
          left: kCardNumberColorHorizontalPadding,
          child: CardNumberColor(
            color: card.color,
            number: card.number,
          ),
        ),
        Positioned(
          top: kCardNumberColorVerticalPadding,
          right: kCardNumberColorHorizontalPadding,
          child: CardNumberColor(
            color: card.color,
            number: card.number,
          ),
        ),
        Positioned(
          bottom: kCardNumberColorVerticalPadding,
          left: kCardNumberColorHorizontalPadding,
          child: CardNumberColor(
            color: card.color,
            number: card.number,
            flip: true,
          ),
        ),
        Positioned(
          bottom: kCardNumberColorVerticalPadding,
          right: kCardNumberColorHorizontalPadding,
          child: CardNumberColor(
            color: card.color,
            number: card.number,
            flip: true,
          ),
        ),
        if (!canDraw)
          Container(
            color: Colors.black38,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Du kannst diese Karte nicht legen',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
          translation: const Offset(-.5, -.25),
          child: Transform.rotate(
            angle: radians(45),
            child: const CustomPaint(
              painter: CardBackPainter(),
            ),
          ),
        ),
      ),
    );
  }
}
