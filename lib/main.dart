import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colorize_lumberdash/colorize_lumberdash.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_lumberdash/firebase_lumberdash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumberdash/lumberdash.dart';
import 'package:superbingo/bloc/blocs/current_game_bloc.dart';

import 'package:superbingo/bloc/blocs/game_configuration_bloc.dart';
import 'package:superbingo/bloc/blocs/info_bloc.dart';
import 'package:superbingo/bloc/blocs/join_game_bloc.dart';
import 'package:superbingo/bloc/blocs/open_games_bloc.dart';
import 'package:superbingo/bloc/events/info_events.dart';
import 'package:superbingo/superbingo.dart';

import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:superbingo/utils/connection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
            create: (_) => PublicGamesBloc(),
            dispose: (_, bloc) => bloc.dispose(),
          ),
          BlocProvider<GameConfigurationBloc>(
            create: (_) => GameConfigurationBloc(Firestore.instance),
          ),
          BlocProvider<JoinGameBloc>(
            create: (_) => JoinGameBloc(Firestore.instance),
          ),
          BlocProvider<CurrentGameBloc>(
            create: (_) => CurrentGameBloc(Firestore.instance),
          ),
          BlocProvider<InfoBloc>(
            create: (_) => InfoBloc(FirebaseAuth.instance)..add(LoadInfos()),
          ),
        ],
        child: SuperBingo(),
      ),
    ),
    onError: Crashlytics.instance.recordError,
  );
}
