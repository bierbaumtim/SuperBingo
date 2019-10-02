import 'package:flutter/material.dart';

import 'package:superbingo/widgets/card_hand.dart';
import 'package:superbingo/widgets/card_stack.dart';
import 'package:superbingo/widgets/player_avatars.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
