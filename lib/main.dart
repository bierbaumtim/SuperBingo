import 'dart:async';

import 'package:flutter/material.dart';

import 'package:superbingo/blocs/game_bloc.dart';
import 'package:superbingo/blocs/open_games_bloc.dart';
import 'package:superbingo/superbingo.dart';

import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runZoned(
    () => runApp(
      MultiProvider(
        child: SuperBingo(),
        providers: [
          Provider<PublicGamesBloc>(
            builder: (_) => PublicGamesBloc(),
            dispose: (_, bloc) => bloc.dispose(),
          ),
          Provider<GameBloc>(
            builder: (_) => GameBloc(),
            dispose: (_, bloc) => bloc.dispose(),
          ),
        ],
      ),
    ),
    onError: Crashlytics.instance.recordError,
  );
}
