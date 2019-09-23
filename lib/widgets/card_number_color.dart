import 'package:flutter/material.dart';

import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/utils/card_utils.dart';

import 'package:vector_math/vector_math.dart' show radians;

class CardNumberColor extends StatelessWidget {
  const CardNumberColor({
    Key key,
    this.color,
    this.number,
    this.flip = false,
    this.isSmall = false,
  }) : super(key: key);

  final CardColor color;
  final CardNumber number;
  final bool flip;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final double iconSize = isSmall ? 14 : 24;
    final double fontSize = isSmall ? 16 : 20;

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
