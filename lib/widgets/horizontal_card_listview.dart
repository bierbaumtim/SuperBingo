import 'package:flutter/material.dart';

import 'package:superbingo/bloc/blocs/current_game_bloc.dart';
import 'package:superbingo/bloc/events/current_game_events.dart';
import 'package:superbingo/constants/enums.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/routes/blur_overlay_route.dart';
import 'package:superbingo/widgets/card_color_decision_card.dart';
import 'package:superbingo/widgets/small_play_card.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

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
    final currentGameBloc = BlocProvider.of<CurrentGameBloc>(context);

    if (cards == null || cards.isEmpty) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: SizedBox(
          height: 175,
          child: ListView.builder(
            itemBuilder: (context, index) => SmallPlayCard(
                card: cards.elementAt(index),
                onCardTap: (card) async {
                  CardColor allowedCardColor;
                  if (card.rule == SpecialRule.joker) {
                    final route = BlurOverlayRoute<CardColor>(
                      builder: (context) => CardColorDecisionCard(),
                    );
                    allowedCardColor =
                        await Navigator.of(context).push<CardColor>(route);
                    if (allowedCardColor == null) return;
                  }
                  currentGameBloc.add(PlayCard(card, allowedCardColor));
                }),
            itemCount: cards.length,
            scrollDirection: Axis.horizontal,
            physics: ClampingScrollPhysics(),
          ),
        ),
      );
    }
  }
}
