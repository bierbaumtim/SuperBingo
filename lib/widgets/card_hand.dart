import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superbingo/blocs/game_bloc.dart';

import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/utils/list_utils.dart';
import 'package:superbingo/widgets/small_play_card.dart';

class CardHand extends StatelessWidget {
  const CardHand({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameBloc = Provider.of<GameBloc>(context);

    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: StreamBuilder<List<GameCard>>(
        stream: gameBloc.handCardStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isNotEmpty) {
              final cards = snapshot.data;
              return Stack(
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
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: Text(
                  'Your done',
                  style: theme.textTheme.body1.copyWith(fontSize: 24),
                ),
              );
            }
          } else {
            // TODO implement empty cardhand ui
            return Container();
          }
        },
      ),
    );
  }
}
