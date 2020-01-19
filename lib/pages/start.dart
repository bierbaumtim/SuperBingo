import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_support/overlay_support.dart';

import '../bloc/blocs/current_game_bloc.dart';
import '../bloc/blocs/game_configuration_bloc.dart';
import '../bloc/blocs/join_game_bloc.dart';
import '../bloc/events/current_game_events.dart';
import '../bloc/events/game_events.dart';
import '../bloc/states/game_states.dart';
import '../bloc/states/join_game_states.dart';

/// Startseite
///
/// Hier landet der Spieler nachdem er die App startet
/// Vor hier aus kann zur Spielerstellung, Spielsuche
/// und Spielerkofiguration navigiert werden.
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
              currentGameBloc.add(StartGame(
                gameId: state.gameId,
                self: state.self,
              ));
              Navigator.of(context).pushNamed('/game');
            } else if (state is JoinGameFailed) {
              showSimpleNotification(
                Text(state.error),
                foreground: Colors.white,
                slideDismiss: true,
              );
            }
          },
        ),
        BlocListener<GameConfigurationBloc, GameConfigurationState>(
          listener: (context, state) {
            if (state is GameCreated) {
              currentGameBloc.add(OpenGameWaitingLobby(
                gameId: state.gameId,
                self: state.self,
              ));
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
              onPressed: () => Navigator.pushNamed(context, '/user_page'),
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
                          BlocProvider.of<GameConfigurationBloc>(context)
                              .add(ResetGameConfiguration());
                        },
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
                        child: const Text('Neues Spiel'),
                      ),
                      RaisedButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/join_game'),
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
                        child: const Text('Spiel beitreten'),
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
