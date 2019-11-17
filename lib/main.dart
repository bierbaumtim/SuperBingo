import 'dart:async';

import 'package:colorize_lumberdash/colorize_lumberdash.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_lumberdash/firebase_lumberdash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumberdash/lumberdash.dart';
import 'package:superbingo/bloc/blocs/current_game_bloc.dart';

import 'package:superbingo/bloc/blocs/game_configuration_bloc.dart';
import 'package:superbingo/bloc/blocs/info_bloc.dart';
import 'package:superbingo/bloc/blocs/join_game_bloc.dart';
import 'package:superbingo/bloc/blocs/open_games_bloc.dart';
import 'package:superbingo/superbingo.dart';

import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:superbingo/utils/connection.dart';

void main() async {
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  putLumberdashToWork(withClients: [
    ColorizeLumberdash(),
    FirebaseLumberdash(
      firebaseAnalyticsClient: FirebaseAnalytics(),
      environment: 'development',
      releaseVersion: '1.0.0',
    ),
  ]);
  await Connection.instance.initConnection();

  runZoned(
    () => runApp(
      MultiProvider(
        providers: [
          Provider<PublicGamesBloc>(
            builder: (_) => PublicGamesBloc(),
            dispose: (_, bloc) => bloc.dispose(),
          ),
          BlocProvider<GameConfigurationBloc>(
            builder: (_) => GameConfigurationBloc(),
          ),
          BlocProvider<JoinGameBloc>(
            builder: (_) => JoinGameBloc(),
          ),
          BlocProvider<CurrentGameBloc>(
            builder: (_) => CurrentGameBloc(),
          ),
          Provider<InfoBloc>(
            builder: (_) => InfoBloc(),
            dispose: (_, bloc) => bloc.dispose(),
          ),
        ],
        child: SuperBingo(),
      ),
    ),
    onError: Crashlytics.instance.recordError,
  );
}
