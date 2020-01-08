import 'package:flutter/material.dart';

import 'package:superbingo/bloc/blocs/current_game_bloc.dart';
import 'package:superbingo/bloc/states/current_game_states.dart';
import 'package:superbingo/constants/enums.dart';
import 'package:superbingo/widgets/horizontal_card_listview.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class CardScrollView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentGameBloc, CurrentGameState>(
      builder: (context, state) {
        Widget child;

        if (state is CurrentGameLoaded) {
          if (state.self.cards.isEmpty) {
            if (state.self.finishPosition == 0) {
              child = Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Material(
                    child: Column(
                      children: <Widget>[
                        const Text(
                          'Nur weil du deine Karten versteckst hast du das Spiel nicht gewonnen.',
                        ),
                        const SizedBox(height: 8),
                        RaisedButton(
                          child: const Text(
                            'Karten suchen...',
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          onPressed: null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              // TODO Prüfung auf finishPosition einbauen. Spieler ist erst fertig wenn die finishPosition > 0 ist
              child = Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Material(
                    child: Text('You´ve finished'),
                  ),
                ),
              );
            }
          } else {
            final cards = state.self.cards;
            final heart =
                cards.where((c) => c.color == CardColor.heart).toList();
            final clover =
                cards.where((c) => c.color == CardColor.clover).toList();
            final diamond =
                cards.where((c) => c.color == CardColor.diamond).toList();
            final spade =
                cards.where((c) => c.color == CardColor.spade).toList();

            child = Expanded(
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
            );
          }
        }

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
            child ?? Container(),
          ],
        );
      },
    );
  }
}
