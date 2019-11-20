import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superbingo/bloc/blocs/current_game_bloc.dart';
import 'package:superbingo/bloc/states/current_game_states.dart';

import 'package:superbingo/widgets/play_card.dart';

import 'package:vector_math/vector_math.dart' show radians;

class CardStack extends StatelessWidget {
  const CardStack({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentGameBloc = BlocProvider.of<CurrentGameBloc>(context);

    return BlocBuilder<CurrentGameBloc, CurrentGameState>(
      bloc: currentGameBloc,
      builder: (context, state) {
        if (state is CurrentGameLoaded) {
          final cards = state.playedCards;

          return Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Stack(
                children: cards.map<Widget>((c) {
                  final rn = Random();
                  final index = cards.indexOf(c);
                  var angle = 1.0 + rn.nextInt(10);
                  double translationY, translationX;
                  var elevation = 0.0;
                  if (c == cards.last) {
                    angle = radians(0);
                  } else {
                    angle = radians(angle);
                    angle = index % 2 == 0 ? angle : -angle;
                  }
                  translationY = 1.0 + rn.nextInt(5);
                  translationX = 1.0 + rn.nextInt(5);
                  if (rn.nextDouble() <= 0.5) {
                    translationX = -translationX;
                  }
                  if (rn.nextDouble() <= 0.5) {
                    translationY = -translationY;
                  }

                  if (index > cards.length - 10) elevation = index - (cards.length - 10.0);

                  return Transform(
                    child: Transform.rotate(
                      child: PlayCard(
                        height: 275,
                        width: 175,
                        card: c,
                        index: index,
                        elevation: elevation,
                      ),
                      angle: angle,
                    ),
                    transform: Matrix4.identity()
                      ..translate(
                        translationX,
                        translationY,
                      ),
                  );
                }).toList(),
              ),
            ),
          );
        } else if (state is CurrentGameWaitingForPlayer) {
          return Container();
        } else {
          return Container();
        }
      },
    );
  }
}
