import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superbingo/blocs/game_bloc.dart';
import 'package:superbingo/blocs/open_games_bloc.dart';
import 'package:superbingo/constants/enums.dart';
import 'package:superbingo/models/app_models/game.dart';
import 'package:superbingo/utils/dialogs.dart';

class JoinGamePage extends StatefulWidget {
  @override
  _JoinGamePageState createState() => _JoinGamePageState();
}

class _JoinGamePageState extends State<JoinGamePage> {
  @override
  Widget build(BuildContext context) {
    final publicGamesBloc = Provider.of<PublicGamesBloc>(context);
    final gameBloc = Provider.of<GameBloc>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Public Games'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => publicGamesBloc.getPublicGames(),
          ),
        ],
      ),
      body: StreamBuilder<List<Game>>(
        stream: publicGamesBloc.publicGamesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isEmpty) {
              return Center(
                child: Text('Es sind keine offenen Spiele verfügbar.'),
              );
            } else {
              return RefreshIndicator(
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    final game = snapshot.data.elementAt(index);

                    return Card(
                      child: ListTile(
                        title: Text(game?.name ?? ''),
                        subtitle: Text('${game?.players?.length ?? 0}/${game?.maxPlayer} Player'),
                        trailing: RaisedButton(
                          color: Colors.deepOrangeAccent,
                          child: Text(
                            'join',
                            style: Theme.of(context).textTheme.body1.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                          onPressed: () async {
                            final result = await gameBloc.joinGame(game.gameID);
                            if (result == JoiningState.success) {
                              Navigator.of(context).pushNamed('/game');
                            } else {
                              Dialogs.showInformationDialog(
                                context,
                                title: 'Fehler',
                                content: messageByJoiningState(result),
                              );
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                onRefresh: publicGamesBloc.getPublicGames,
              );
            }
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error is PermissionError ? (snapshot.error as PermissionError).message : 'An error occured',
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  String messageByJoiningState(JoiningState state) {
    if (state == JoiningState.dataIssue) {
      return 'Beim erstellen des Spiels ist ein Fehler aufgetreten. Du kannst diesem Spiel daher nicht beitreten.';
    } else if (state == JoiningState.playerAlreadyJoined) {
      return 'Beim Verlassen des Spiels ist ein Fehler aufgetreten. Du kannstt diesem Spiel daher nicht erneut beitreten.';
    } else {
      return 'Aufgrund eines Fehler kannst du dem Spiel nicht beitreten. Versuche es bitte später erneut.';
    }
  }
}
