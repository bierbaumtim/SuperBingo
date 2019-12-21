import 'package:flutter/material.dart';

import 'package:superbingo/bloc/blocs/current_game_bloc.dart';
import 'package:superbingo/bloc/states/current_game_states.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/widgets/horizontal_card_listview.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class CardScrollView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentGameBloc = BlocProvider.of<CurrentGameBloc>(context);

    return BlocBuilder<CurrentGameBloc, CurrentGameState>(
      bloc: currentGameBloc,
      builder: (context, state) {
        if (state is CurrentGameLoaded) {
          if (state.handCards.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text('You´ve finished'),
              ),
            );
          } else {
            final cards = state.handCards;
            final heart =
                cards.where((c) => c.color == CardColor.heart).toList();
            final clover =
                cards.where((c) => c.color == CardColor.clover).toList();
            final diamond =
                cards.where((c) => c.color == CardColor.diamond).toList();
            final spade =
                cards.where((c) => c.color == CardColor.spade).toList();

            return Column(
              children: <Widget>[
                SizedBox(
                  height: 12.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 30,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.all(
                          Radius.circular(12.0),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 18.0,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        HorizontalCardList(
                          cards: clover,
                        ),
                        HorizontalCardList(
                          cards: spade,
                        ),
                        HorizontalCardList(
                          cards: diamond,
                        ),
                        HorizontalCardList(
                          cards: heart,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        } else {
          return Container();
        }
      },
    );
  }
}
