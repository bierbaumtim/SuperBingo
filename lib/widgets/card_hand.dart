import 'package:flutter/material.dart';

import 'package:superbingo/bloc/blocs/current_game_bloc.dart';
import 'package:superbingo/bloc/states/current_game_states.dart';
import 'package:superbingo/utils/list_utils.dart';
import 'package:superbingo/widgets/small_play_card.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template cardhand}
/// Dieses Widget bildet die aufgefächerten Karten eines Spielers nach.
/// {@endtemplate}
class CardHand extends StatelessWidget {
  /// {@macro cardhand}
  const CardHand({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentGameBloc = BlocProvider.of<CurrentGameBloc>(context);

    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: BlocBuilder<CurrentGameBloc, CurrentGameState>(
        bloc: currentGameBloc,
        builder: (context, state) {
          if (state is CurrentGameLoaded) {
            if (state.self.cards.isNotEmpty) {
              final cards = state.self.cards;
              return Stack(
                alignment: Alignment.center,
                children: cards.map<Widget>((c) {
                  final index = cards.indexOf(c);

                  var angle = 160 / cards.length;
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

                  /// ignore: missing_required_param
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
            return Container();
          }
        },
      ),
    );
  }
}
