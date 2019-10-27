import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:superbingo/blocs/game_bloc.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/utils/dialogs.dart';

import 'package:superbingo/widgets/card_stack.dart';
import 'package:superbingo/widgets/player_avatars.dart';
import 'package:superbingo/widgets/small_play_card.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    final gameBloc = Provider.of<GameBloc>(context);

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
          await gameBloc.leaveGame();
        }
        return Future(() => result);
      },
      child: SlidingUpPanel(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.0),
          topRight: Radius.circular(18.0),
        ),
        color: Theme.of(context).canvasColor,
        minHeight: 95,
        maxHeight: MediaQuery.of(context).size.height - kToolbarHeight - 20,
        parallaxEnabled: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        body: Scaffold(
          backgroundColor: Colors.deepOrangeAccent,
          endDrawer: Drawer(
            child: Column(
              children: <Widget>[],
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.deepOrangeAccent,
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
              ],
            ),
          ),
        ),
        panel: CardScrollView(),
      ),
    );
  }
}

class CardScrollView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameBloc = Provider.of<GameBloc>(context);

    return StreamBuilder<List<GameCard>>(
      stream: gameBloc.handCardStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text('You´ve finished'),
              ),
            );
          } else {
            final cards = snapshot.data;
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
                      decoration:
                          BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.all(Radius.circular(12.0))),
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
                        if (clover.isNotEmpty) ...[
                          SizedBox(
                            height: 175,
                            child: ListView.builder(
                              itemBuilder: (context, index) => SmallPlayCard(
                                card: clover.elementAt(index),
                              ),
                              itemCount: clover.length,
                              scrollDirection: Axis.horizontal,
                              physics: ClampingScrollPhysics(),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (spade.isNotEmpty) ...[
                          SizedBox(
                            height: 175,
                            child: ListView.builder(
                              itemBuilder: (context, index) => SmallPlayCard(
                                card: spade.elementAt(
                                  index,
                                ),
                              ),
                              itemCount: spade.length,
                              scrollDirection: Axis.horizontal,
                              physics: ClampingScrollPhysics(),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (diamond.isNotEmpty) ...[
                          SizedBox(
                            height: 175,
                            child: ListView.builder(
                              itemBuilder: (context, index) => SmallPlayCard(
                                card: diamond.elementAt(index),
                              ),
                              itemCount: diamond.length,
                              scrollDirection: Axis.horizontal,
                              physics: ClampingScrollPhysics(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        if (heart.isNotEmpty) ...[
                          SizedBox(
                            height: 175,
                            child: ListView.builder(
                              itemBuilder: (context, index) => SmallPlayCard(
                                card: heart.elementAt(index),
                              ),
                              itemCount: heart.length,
                              scrollDirection: Axis.horizontal,
                              physics: ClampingScrollPhysics(),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
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
