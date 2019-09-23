import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

import 'package:superbingo/blocs/open_games_bloc.dart';

import 'package:provider/provider.dart';

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
                        Navigator.of(context).pushNamed('/new_game');
                      },
                      child: const Text('New game'),
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
                        Provider.of<PublicGamesBloc>(context).getPublicGames();
                        Navigator.of(context).pushNamed('/join_game');
                      },
                      child: const Text('Join game'),
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
