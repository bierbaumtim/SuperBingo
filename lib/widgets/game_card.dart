import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blocs/join_game_bloc.dart';
import '../bloc/events/join_game_events.dart';
import '../models/app_models/game.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    Key key,
    @required this.game,
  }) : super(key: key);

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(game?.name ?? ''),
        subtitle: Text(
          '${game?.players?.length ?? 0}/${game?.maxPlayer} Player',
        ),
        trailing: RaisedButton(
          color: Colors.deepOrangeAccent,
          onPressed: () => context.read<JoinGameBloc>().add(
                JoinGame(
                  game.gameID,
                ),
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            'join',
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ),
    );
  }
}
