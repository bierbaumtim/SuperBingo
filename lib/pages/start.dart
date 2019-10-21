import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final username = prefs.getString('username') ?? '';
              Navigator.pushNamed(context, '/user_page', arguments: username);
            },
          ),
        ],
      ),
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
              left: 36,
              right: 36,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
