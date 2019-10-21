import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:superbingo/blocs/game_bloc.dart';
import 'package:superbingo/models/app_models/card.dart';

import 'package:superbingo/widgets/card_hand.dart';
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
    return WillPopScope(
      onWillPop: () {
        return Future(() => true);
      },
      child: SlidingUpPanel(
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
                const CardHand(),
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
            final heart =
                cards.where((c) => c.color == CardColor.heart).toList();
            final clover =
                cards.where((c) => c.color == CardColor.clover).toList();
            final diamond =
                cards.where((c) => c.color == CardColor.diamond).toList();
            final spade =
                cards.where((c) => c.color == CardColor.spade).toList();

            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
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
                  const SizedBox(height: 10),
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
              ),
            );
          }
        } else {
          Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
