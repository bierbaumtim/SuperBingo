import 'package:flutter/material.dart';

import '../../constants/enums.dart';
import '../../models/app_models/card.dart';
import 'card_hand_stack.dart';

class MobileCardHand extends StatelessWidget {
  final List<GameCard> cards;

  const MobileCardHand({
    Key key,
    this.cards,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final heart = cards.where((c) => c.color == CardColor.heart).toList();
    final clover = cards.where((c) => c.color == CardColor.clover).toList();
    final diamond = cards.where((c) => c.color == CardColor.diamond).toList();
    final spade = cards.where((c) => c.color == CardColor.spade).toList();

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            if (heart.isNotEmpty)
              CardHandStack(
                cards: heart,
                maxWidth: constraints.maxWidth,
                totalCardsNumber: cards.length,
              ),
            if (clover.isNotEmpty)
              CardHandStack(
                cards: clover,
                maxWidth: constraints.maxWidth,
                totalCardsNumber: cards.length,
              ),
            if (diamond.isNotEmpty)
              CardHandStack(
                cards: diamond,
                maxWidth: constraints.maxWidth,
                totalCardsNumber: cards.length,
              ),
            if (spade.isNotEmpty)
              CardHandStack(
                cards: spade,
                maxWidth: constraints.maxWidth,
                totalCardsNumber: cards.length,
              ),
          ],
        ),
      ),
    );
  }
}
