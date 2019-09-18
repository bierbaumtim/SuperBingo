import 'package:flutter/material.dart';
import 'package:superbingo/models/app_models/card.dart' as cardModel;
import 'package:superbingo/pages/game_page.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Text(
                'SuperBingo',
                style: TextStyle(
                  fontSize: 45,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: 75,
              left: 0,
              right: 0,
              child: Center(
                child: RaisedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => GamePage()),
                    );
                  },
                  child: const Text('Start game'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 36,
                  ),
                  textColor: Colors.white,
                  color: Colors.orange,
                  elevation: 6.0,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: PlayCard(),
            )
          ],
        ),
      ),
    );
  }
}

class PlayCard extends StatelessWidget {
  final cardModel.Card card;
  final double height;
  final double width;

  const PlayCard({
    Key key,
    this.card,
    this.height = 175,
    this.width = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: <Widget>[],
        ),
      ),
    );
  }
}
