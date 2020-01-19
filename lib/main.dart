import 'dart:async';

import 'package:flutter/material.dart';

import 'package:provider/single_child_widget.dart';
import 'package:colorize_lumberdash/colorize_lumberdash.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_lumberdash/firebase_lumberdash.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumberdash/lumberdash.dart';
import 'package:provider/provider.dart';

import 'bloc/blocs/current_game_bloc.dart';
import 'bloc/blocs/game_configuration_bloc.dart';
import 'bloc/blocs/info_bloc.dart';
import 'bloc/blocs/interaction_bloc.dart';
import 'bloc/blocs/join_game_bloc.dart';
import 'bloc/blocs/open_games_bloc.dart';
import 'bloc/events/info_events.dart';
import 'services/network_service.dart';
import 'superbingo.dart';
import 'utils/connection.dart';

/// ignore: avoid_void_async
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

  final networkService = NetworkService();

  runZoned(
    () => runApp(
      MultiProvider(
        providers: <SingleChildWidget>[
          Provider<PublicGamesBloc>(
            create: (_) => PublicGamesBloc(),
            dispose: (_, bloc) => bloc.dispose(),
          ),
          Provider<NetworkService>(
            create: (context) => networkService,
            dispose: (_, service) => service.dispose(),
          ),
        ],
        child: MultiBlocProvider(
          providers: <BlocProvider>[
            BlocProvider<GameConfigurationBloc>(
              create: (context) => GameConfigurationBloc(networkService),
            ),
            BlocProvider<JoinGameBloc>(
              create: (context) => JoinGameBloc(networkService),
            ),
            BlocProvider<CurrentGameBloc>(
              create: (context) => CurrentGameBloc(networkService),
            ),
            BlocProvider<InteractionBloc>(
              create: (_) => InteractionBloc(networkService),
            ),
            BlocProvider<InfoBloc>(
              create: (_) => InfoBloc(FirebaseAuth.instance)..add(LoadInfos()),
            ),
          ],
          child: Builder(
            builder: (context) => SuperBingo(),
          ),
        ),
      ),
    ),
    onError: Crashlytics.instance.recordError,
  );
}
