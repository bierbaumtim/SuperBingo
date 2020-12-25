import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blocs/current_game_bloc.dart';
import '../bloc/events/current_game_events.dart' as game_events;
import '../constants/enums.dart';
import '../models/app_models/card.dart';
import '../routes/blur_overlay_route.dart';
import 'card_color_decision_card.dart';
import 'play_card.dart';

///{@template horizontalcardlist}
/// Erzeugt ein ListView, mit der `scrollDirection` `Axis.horizontal` und den `cards`.
///{@endtemplate}
class HorizontalCardList extends StatelessWidget {
  /// Liste der Karten die angezeigt werden sollen
  final List<GameCard> cards;

  /// {@macro horizontalcardlist}
  const HorizontalCardList({Key key, this.cards}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cards == null || cards.isEmpty) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: SizedBox(
          height: 175,
          child: ListView.builder(
            itemBuilder: (context, index) => PlayCard(
              card: cards.elementAt(index),
              onCardTap: (card) async {
                CardColor allowedCardColor;
                if (card.rule == SpecialRule.joker) {
                  final route = BlurOverlayRoute<CardColor>(
                    builder: (context) => const CardColorDecisionCard(),
                  );
                  allowedCardColor =
                      await Navigator.of(context).push<CardColor>(route);
                  if (allowedCardColor == null) return;
                }
                context
                    .read<CurrentGameBloc>()
                    .add(game_events.PlayCard(card, allowedCardColor));
              },
            ),
            itemCount: cards.length,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
          ),
        ),
      );
    }
  }
}
