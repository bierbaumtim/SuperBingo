import 'package:flutter/material.dart';

import 'package:superbingo/blocs/open_games_bloc.dart';
import 'package:superbingo/superbingo.dart';

import 'package:provider/provider.dart';

void main() async {
  runApp(
    MultiProvider(
      child: SuperBingo(),
      providers: [
        Provider<PublicGamesBloc>(
          builder: (_) => PublicGamesBloc(),
          dispose: (_, bloc) => bloc.dispose(),
        ),
      ],
    ),
  );
}
