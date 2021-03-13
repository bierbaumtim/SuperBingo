import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:superbingo/models/app_models/card.dart';

import 'package:supercharged/supercharged.dart';

import '../play_card/play_card.dart';

class CardHandStack extends StatefulWidget {
  final List<GameCard> cards;
  final int totalCardsNumber;
  final double maxWidth;

  const CardHandStack({
    Key? key,
    required this.cards,
    required this.totalCardsNumber,
    required this.maxWidth,
  }) : super(key: key);

  @override
  _CardHandStackState createState() => _CardHandStackState();
}

class _CardHandStackState extends State<CardHandStack>
    with SingleTickerProviderStateMixin {
  static const double cardOffset = 16;

  bool get isExpanded => expansionController.value > 5 / 1E5;

  late AnimationController expansionController;
  late CurvedAnimation expansionAnimation;

  @override
  void initState() {
    super.initState();
    expansionController = AnimationController(
      vsync: this,
      value: isExpanded ? 1 : 0,
      duration: const Duration(milliseconds: 550),
    );
    expansionAnimation = CurvedAnimation(
      parent: expansionController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    expansionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: expansionAnimation,
      builder: (context, child) => ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isExpanded
              ? getOffsetByIndexAndExpansionStatus(widget.cards.lastIndex!) +
                  (100 - cardOffset) +
                  kMinInteractiveDimension
              : 100 + kMinInteractiveDimension,
          maxHeight: 175.0 + 16,
        ),
        child: Builder(
          builder: (context) => Stack(
            children: [
              ...widget.cards
                  .mapIndexedSC<Widget>(
                    (card, i) => Positioned(
                      left: getOffsetByIndexAndExpansionStatus(i),
                      child: PlayCard(
                        card: card,
                        onCardTap: (card) {},
                        elevation: i * 1.0,
                        isFlipped: false,
                        shouldPaint:
                            isExpanded || i >= widget.cards.lastIndex! - 1,
                      ),
                    ),
                  )
                  .toList(),
              if (!isExpanded)
                Positioned(
                  right: 0,
                  top: 87.5,
                  child: _BlurredCardHandStackButton(
                    translation: const Offset(.3, -.5),
                    onPressed: () => expansionController.forward(),
                    icon: Icons.chevron_right,
                  ),
                )
              else if (expansionAnimation.value > 0.9) ...[
                Positioned(
                  left: 0,
                  top: 87.5,
                  child: _BlurredCardHandStackButton(
                    translation: const Offset(0, -.5),
                    onPressed: () => expansionController.reverse(),
                    icon: Icons.chevron_left,
                  ),
                ),
                Positioned(
                  left: getOffsetByIndexAndExpansionStatus(
                    widget.cards.lastIndex! + 1,
                  ),
                  top: 87.5,
                  child: _BlurredCardHandStackButton(
                    translation: const Offset(-.5, -.5),
                    onPressed: () => expansionController.reverse(),
                    icon: Icons.chevron_left,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  double getOffsetByIndexAndExpansionStatus(int index) {
    double value = 0.0;
    if (isExpanded) {
      /// Formel: (Card * index * Animation) - (Überlappung * index * Animation)
      value = (100 - cardOffset) * index * expansionAnimation.value;
    } else {
      if (index == widget.cards.lastIndex) {
        value = cardOffset / 2;
      }
    }
    return value + (kMinInteractiveDimension / 2);
  }
}

class _BlurredCardHandStackButton extends StatelessWidget {
  const _BlurredCardHandStackButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.translation,
  }) : super(key: key);

  final VoidCallback onPressed;
  final IconData icon;
  final Offset translation;

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation: translation,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: IconButton(
            color: Colors.orange,
            icon: Icon(icon),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
