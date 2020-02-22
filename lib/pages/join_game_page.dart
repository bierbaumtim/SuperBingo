import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:superbingo/widgets/loading_widget.dart';

import '../bloc/blocs/join_game_bloc.dart';
import '../bloc/blocs/open_games_bloc.dart';
import '../bloc/events/join_game_events.dart';
import '../bloc/states/join_game_states.dart';
import '../constants/enums.dart';
import '../models/app_models/game.dart';

/// [JoinGamePage] zeigt alle öffentlichen Spiele an.
///
/// Von hier aus kann der Spieler einem Spiel beitreten.
class JoinGamePage extends StatefulWidget {
  @override
  _JoinGamePageState createState() => _JoinGamePageState();
}

class _JoinGamePageState extends State<JoinGamePage> {
  OverlayEntry _joiningOverlay;

  @override
  void dispose() {
    hideJoiningOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final publicGamesBloc = Provider.of<PublicGamesBloc>(context);
    final joinGameBloc = BlocProvider.of<JoinGameBloc>(context);

    return BlocListener<JoinGameBloc, JoinGameState>(
      bloc: joinGameBloc,
      listener: (context, state) {
        if (state is JoiningGame) {
          showJoiningOverlay(context);
        } else if (state is JoinGameFailed) {
          hideJoiningOverlay();
        } else {
          hideJoiningOverlay();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text('Public Games'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: publicGamesBloc.getPublicGames,
            ),
          ],
        ),
        body: StreamBuilder<List<Game>>(
          stream: publicGamesBloc.publicGamesStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.isEmpty) {
                return const Center(
                  child: Text('Es sind keine offenen Spiele verfügbar.'),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: publicGamesBloc.getPublicGames,
                  child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      final game = snapshot.data.elementAt(index);

                      return Card(
                        child: ListTile(
                          title: Text(game?.name ?? ''),
                          subtitle: Text(
                            '${game?.players?.length ?? 0}/${game?.maxPlayer} Player',
                          ),
                          trailing: RaisedButton(
                            color: Colors.deepOrangeAccent,
                            onPressed: () {
                              joinGameBloc.add(JoinGame(game.gameID));
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              'join',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error is PermissionError
                      ? (snapshot.error as PermissionError).message
                      : 'Beim Laden der Spiele ist ein Fehler aufgetreten.\nBitte versuche es später erneut.',
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
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
