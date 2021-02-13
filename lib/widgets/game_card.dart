import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blocs/info_bloc.dart';
import '../bloc/blocs/join_game_bloc.dart';
import '../bloc/events/join_game_events.dart';
import '../bloc/states/info_states.dart';
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
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(game?.name ?? ''),
        subtitle: Text(
          '${game?.players?.length ?? 0}/${game?.maxPlayer} Player',
        ),
        trailing: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              Colors.deepOrangeAccent,
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          onPressed: () async {
            if (await _checkPlayer(context)) {
              context.read<JoinGameBloc>().add(
                    JoinGame(
                      game.gameID,
                    ),
                  );
            }
          },
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

  Future<bool> _checkPlayer(BuildContext context) async {
    if (context.read<InfoBloc>().state is! InfosLoaded) {
      final result =
          await Navigator.of(context).pushNamed('/user_page') as String;
      return result != null && result.isNotEmpty;
    }
    return true;
  }
}
