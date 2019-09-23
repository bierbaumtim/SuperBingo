import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superbingo/blocs/open_games_bloc.dart';

class JoinGamePage extends StatefulWidget {
  @override
  _JoinGamePageState createState() => _JoinGamePageState();
}

class _JoinGamePageState extends State<JoinGamePage> {
  @override
  Widget build(BuildContext context) {
    final publicGamesBloc = Provider.of<PublicGamesBloc>(context);

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
      body: StreamBuilder<List<DocumentSnapshot>>(
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
                        title: Text(game.data['name'] ?? ''),
                        subtitle: Text(
                            '${game.data['player'].length}/${game.data['maxPlayer']} Player'),
                        trailing: RaisedButton(
                          color: Colors.deepOrangeAccent,
                          child: Text(
                            'join',
                            style: Theme.of(context).textTheme.body1.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                          onPressed: () {},
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
                snapshot.error is PermissionError
                    ? (snapshot.error as PermissionError).message
                    : 'An error occured',
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
}
