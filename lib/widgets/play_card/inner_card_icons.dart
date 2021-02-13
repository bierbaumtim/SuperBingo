import 'package:flutter/material.dart';

import '../../constants/enums.dart';
import '../../utils/card_utils.dart';

class InnerCardIcons extends StatelessWidget {
  /// Farbe der Spielkarte
  final CardColor color;
  /// Konfiguration, ob die Icons klein oder groß dargestellt werden sollen
  final bool isSmall;

  const InnerCardIcons({
    Key key,
    this.color,
    this.isSmall = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = isSmall ? 20.0 : 36.0;

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
