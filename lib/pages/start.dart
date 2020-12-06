import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:superbingo/bloc/blocs/open_games_bloc.dart';
import 'package:superbingo/constants/enums.dart';
import 'package:superbingo/models/app_models/game.dart';
import 'package:superbingo/widgets/game_card.dart';
import 'package:superbingo/widgets/loading_widget.dart';

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
  OverlayEntry _joiningOverlay;

  @override
  void dispose() {
    hideJoiningOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentGameBloc = BlocProvider.of<CurrentGameBloc>(context);
    final publicGamesBloc = Provider.of<PublicGamesBloc>(context);

    return MultiBlocListener(
      listeners: <BlocListener>[
        BlocListener<JoinGameBloc, JoinGameState>(
          listener: (context, state) {
            if (state is JoiningGame) {
              showJoiningOverlay(context);
            } else if (state is JoinGameFailed) {
              hideJoiningOverlay();
            } else {
              hideJoiningOverlay();
            }
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
                foreground: Colors.white,
                slideDismiss: true,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        //   actions: <Widget>[
        //     IconButton(
        //       icon: const Icon(Icons.person),
        //       onPressed: () => Navigator.pushNamed(context, '/user_page'),
        //     ),
        //   ],
        // ),
        body: StreamBuilder<List<Game>>(
          stream: publicGamesBloc.publicGamesStream,
          builder: (context, snapshot) => CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () => Navigator.pushNamed(context, '/user_page'),
                  ),
                ],
                expandedHeight: MediaQuery.of(context).size.height / 3,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text('SuperBingo'),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: RaisedButton(
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
                ),
              ),
              if (snapshot.hasData)
                if (snapshot.data.isEmpty)
                  SliverFillRemaining(
                    child: const Center(
                      child: Text('Es sind keine offenen Spiele verfügbar.'),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => GameCard(
                        game: snapshot.data.elementAt(index),
                      ),
                      childCount: snapshot.data.length,
                    ),
                  )
              else if (snapshot.hasError)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      snapshot.error is PermissionError
                          ? (snapshot.error as PermissionError).message
                          : 'Beim Laden der Spiele ist ein Fehler aufgetreten.\nBitte versuche es später erneut.',
                    ),
                  ),
                )
              else
                SliverFillRemaining(
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
        // body: SafeArea(
        //   child: Stack(
        //     children: <Widget>[
        //       const Align(
        //         child: Text(
        //           'SuperBingo',
        //           style: TextStyle(
        //             fontSize: 45,
        //             fontFamily: 'Georgia',
        //             color: Colors.white,
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //       ),
        //       Positioned(
        //         bottom: 75,
        //         left: 36,
        //         right: 36,
        //         child: Center(
        //           child: Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceAround,
        //             children: <Widget>[
        //               RaisedButton(
        //                 onPressed: () async {
        //                   await Navigator.of(context).pushNamed('/new_game');
        //                   BlocProvider.of<GameConfigurationBloc>(context)
        //                       .add(ResetGameConfiguration());
        //                 },
        //                 shape: RoundedRectangleBorder(
        //                   borderRadius: BorderRadius.circular(50),
        //                 ),
        //                 padding: const EdgeInsets.symmetric(
        //                   vertical: 12,
        //                   horizontal: 24,
        //                 ),
        //                 textColor: Colors.white,
        //                 color: Colors.deepOrange,
        //                 elevation: 6.0,
        //                 child: const Text('Neues Spiel'),
        //               ),
        //               RaisedButton(
        //                 onPressed: () =>
        //                     Navigator.of(context).pushNamed('/join_game'),
        //                 shape: RoundedRectangleBorder(
        //                   borderRadius: BorderRadius.circular(50),
        //                 ),
        //                 padding: const EdgeInsets.symmetric(
        //                   vertical: 12,
        //                   horizontal: 24,
        //                 ),
        //                 textColor: Colors.white,
        //                 color: Colors.deepOrange,
        //                 elevation: 6.0,
        //                 child: const Text('Spiel beitreten'),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }

  String messageByJoiningState(JoiningState state) {
    if (state == JoiningState.dataIssue) {
      return 'Beim erstellen des Spiels ist ein Fehler aufgetreten. Du kannst diesem Spiel daher nicht beitreten.';
    } else if (state == JoiningState.playerAlreadyJoined) {
      return 'Beim Verlassen des Spiels ist ein Fehler aufgetreten. Du kannst diesem Spiel daher nicht erneut beitreten.';
    } else {
      return 'Aufgrund eines Fehler kannst du dem Spiel nicht beitreten. Versuche es bitte später erneut.';
    }
  }

  void showJoiningOverlay(BuildContext context) {
    _joiningOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: <Widget>[
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
            child: Material(
              color: Colors.black.withOpacity(0.25),
              child: const Loading(
                content: 'Du trittst dem Spiel bei.',
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_joiningOverlay);
  }

  void hideJoiningOverlay() {
    if (_joiningOverlay != null) {
      _joiningOverlay?.remove();
      _joiningOverlay = null;
    }
  }
}
