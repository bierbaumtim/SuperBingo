import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:superbingo/bloc/blocs/current_game_bloc.dart';
import 'package:superbingo/bloc/states/current_game_states.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/utils/dialogs.dart';

import 'package:superbingo/widgets/card_stack.dart';
import 'package:superbingo/widgets/avatars/player_avatars.dart';
import 'package:superbingo/widgets/small_play_card.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    final currentGameBloc = BlocProvider.of<CurrentGameBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        final result = await Dialogs.showDecisionDialog(
          context,
          title: 'Hinweis',
          content: 'Wollen Sie wirklich das Spiel verlassen.',
          noText: 'Nein',
          yesText: 'Ja',
        );
        if (result) {
          await currentGameBloc.leaveGame();
        }
        return Future(() => result);
      },
      child: BlocBuilder<CurrentGameBloc, CurrentGameState>(
        builder: (context, state) {
          if (state is CurrentGameLoaded || state is CurrentGameWaitingForPlayer) {
            var title;
            if (state is CurrentGameLoaded) {
              title = state.game.name;
            } else if (state is CurrentGameWaitingForPlayer) {
              title = state.game.name;
            } else {
              title = 'Aktuelles Spiel';
            }

            return SlidingUpPanel(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0),
              ),
              color: Theme.of(context).canvasColor,
              minHeight: state is CurrentGameLoaded ? 95 : 0,
              maxHeight: MediaQuery.of(context).size.height - kToolbarHeight - 20,
              parallaxEnabled: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              isDraggable: state is CurrentGameLoaded,
              body: Scaffold(
                backgroundColor: Colors.deepOrangeAccent,
                endDrawer: Drawer(
                  child: Column(
                    children: <Widget>[],
                  ),
                ),
                appBar: AppBar(
                  backgroundColor: Colors.deepOrangeAccent,
                  title: Text(title),
                ),
                body: SafeArea(
                  child: Stack(
                    children: <Widget>[
                      const CardStack(),
                      // const CardHand(),
                      const PlayerAvatars(),
                      Positioned(
                        bottom: MediaQuery.of(context).size.height / 3,
                        right: 8,
                        child: FloatingActionButton(
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.flag),
                          onPressed: () {},
                        ),
                      ),
                      if (state is CurrentGameWaitingForPlayer) ...[],
                    ],
                  ),
                ),
              ),
              panel: CardScrollView(),
            );
          }

          return Scaffold();
        },
      ),
    );
  }
}

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
            final heart = cards.where((c) => c.color == CardColor.heart).toList();
            final clover = cards.where((c) => c.color == CardColor.clover).toList();
            final diamond = cards.where((c) => c.color == CardColor.diamond).toList();
            final spade = cards.where((c) => c.color == CardColor.spade).toList();

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
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

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
            itemBuilder: (context, index) => SmallPlayCard(
              card: cards.elementAt(index),
            ),
            itemCount: cards.length,
            scrollDirection: Axis.horizontal,
            physics: ClampingScrollPhysics(),
          ),
        ),
      );
    }
  }
}
