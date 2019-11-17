import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superbingo/bloc/blocs/current_game_bloc.dart';
import 'package:superbingo/bloc/blocs/game_configuration_bloc.dart';
import 'package:superbingo/bloc/blocs/join_game_bloc.dart';

import 'package:superbingo/bloc/blocs/open_games_bloc.dart';

import 'package:provider/provider.dart';
import 'package:superbingo/bloc/events/current_game_events.dart';
import 'package:superbingo/bloc/events/game_events.dart';
import 'package:superbingo/bloc/states/game_states.dart';
import 'package:superbingo/bloc/states/join_game_states.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    final currentGameBloc = BlocProvider.of<CurrentGameBloc>(context);

    return MultiBlocListener(
      listeners: <BlocListener>[
        BlocListener<JoinGameBloc, JoinGameState>(
          listener: (context, state) {
            if (state is JoinedGame) {
              currentGameBloc.add(StartGame(state.gameId));
            } else if (state is JoinGameFailed) {
              showSimpleNotification(
                Text(state.error),
              );
            }
          },
        ),
        BlocListener<GameConfigurationBloc, GameConfigurationState>(
          listener: (context, state) {
            if (state is GameCreated) {
              currentGameBloc.add(StartGame(state.gameId));
            } else if (state is GameCreationFailed) {
              showSimpleNotification(
                Text(state.error),
              );
            }
          },
        ),
      ],
      child: Scaffold(
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
                        onPressed: () async {
                          await Navigator.of(context).pushNamed('/new_game');
                          BlocProvider.of<GameConfigurationBloc>(context).add(ResetGameConfiguration());
                        },
                        child: const Text('Neues Spiel'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
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
                        child: const Text('Spiel beitreten'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
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
      ),
    );
  }
}
