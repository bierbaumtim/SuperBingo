import 'package:flutter/material.dart';

import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/utils/list_utils.dart';
import 'package:superbingo/widgets/small_play_card.dart';

class CardHand extends StatelessWidget {
  final List<GameCard> cards;

  const CardHand({
    Key key,
    @required this.cards,
  })  : assert(cards != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Stack(
        alignment: Alignment.center,
        children: cards.map<Widget>((c) {
          final index = cards.indexOf(c);

          double angle = 160 / cards.length;
          double rotationAngle;
          if (angle >= 50) angle = 20;
          final middle = getMiddleIndex(cards);

          if (index >= middle || index <= middle) {
            angle = -90 - (angle * (middle - index));
            rotationAngle = 270 + angle;
          } else {
            angle = -90;
            rotationAngle = 0;
          }

          return SmallPlayCard(
            card: c,
            angle: angle,
            index: index,
            rotationAngle: rotationAngle,
          );
        }).toList(),
      ),
    );
  }
}
