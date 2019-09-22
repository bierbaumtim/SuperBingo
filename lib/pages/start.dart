import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

import 'package:superbingo/pages/game_page.dart';
import 'package:superbingo/pages/join_game_page.dart';

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
                  fontFamily: 'Georgia',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: 75,
              left: 50,
              right: 50,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        showSimpleNotification(
                          Text('Test Notification'),
                          background: Colors.deepOrange,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => GamePage()),
                        );
                      },
                      child: const Text(
                        'New game',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 36,
                      ),
                      textColor: Colors.white,
                      color: Colors.deepOrange,
                      elevation: 6.0,
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => JoinGamePage()),
                        );
                      },
                      child: const Text(
                        'Join game',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 36,
                      ),
                      textColor: Colors.white,
                      color: Colors.deepOrange,
                      elevation: 6.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
