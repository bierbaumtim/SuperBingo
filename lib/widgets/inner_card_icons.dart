import 'package:flutter/material.dart';

import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/utils/card_utils.dart';

class InnerCardIcons extends StatelessWidget {
  final CardColor color;
  final bool isSmall;

  const InnerCardIcons({
    Key key,
    this.color,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double size = isSmall ? 20 : 36;

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(
              getIconByCardColor(color),
              color: getColorByCardColor(color),
              size: size,
            ),
            Icon(
              getIconByCardColor(color),
              color: getColorByCardColor(color),
              size: size,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              getIconByCardColor(color),
              color: getColorByCardColor(color),
              size: size,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(
              getIconByCardColor(color),
              color: getColorByCardColor(color),
              size: size,
            ),
            Icon(
              getIconByCardColor(color),
              color: getColorByCardColor(color),
              size: size,
            ),
          ],
        ),
      ],
    );
  }
}
