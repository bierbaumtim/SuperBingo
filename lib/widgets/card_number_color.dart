import 'package:flutter/material.dart';

import 'package:vector_math/vector_math.dart' show radians;

import '../constants/enums.dart';
import '../utils/card_utils.dart';

class CardNumberColor extends StatelessWidget {
  const CardNumberColor({
    Key key,
    this.color,
    this.number,
    this.flip = false,
    this.isSmall = false,
  }) : super(key: key);

  /// Farbe der Spielkarte
  final CardColor color;

  /// Nummer der Spielkarte
  final CardNumber number;

  /// Konfiguration, ob das Symbol um 180° gedreht werden soll
  final bool flip;

  /// Konfiguration, ob Symbol klein oder groß dargestellt werden soll
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final iconSize = isSmall ? 14.0 : 24.0;
    final fontSize = isSmall ? 16.0 : 20.0;

    return Container(
      color: Colors.white,
      child: Transform.rotate(
        angle: radians(flip ? 180 : 0),
        child: Column(
          children: <Widget>[
            if (!flip)
              Text(
                getTextByCardNumber(number),
                style: TextStyle(
                  fontSize: fontSize,
                  fontFamily: 'Georgia',
                  color: getColorByCardColor(color),
                ),
              ),
            Icon(
              getIconByCardColor(color),
              color: getColorByCardColor(color),
              size: iconSize,
            ),
            if (flip)
              Text(
                getTextByCardNumber(number),
                style: TextStyle(
                  fontSize: fontSize,
                  fontFamily: 'Georgia',
                  color: getColorByCardColor(color),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
