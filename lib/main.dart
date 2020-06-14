import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firedart/firedart.dart';
import 'package:provider/single_child_widget.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'auth/secure_stoage_impl.dart';
import 'auth/secure_token_repository.dart';
import 'auth/secure_token_store.dart';
import 'bloc/blocs/current_game_bloc.dart';
import 'bloc/blocs/game_configuration_bloc.dart';
import 'bloc/blocs/info_bloc.dart';
import 'bloc/blocs/interaction_bloc.dart';
import 'bloc/blocs/join_game_bloc.dart';
import 'bloc/blocs/open_games_bloc.dart';
import 'constants/firestore_data.dart';
import 'services/network_service.dart';
import 'superbingo.dart';
import 'utils/connection.dart';

/// ignore: avoid_void_async
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    FlutterError.onError = Crashlytics.instance.recordFlutterError;
  }
  final tokenRepo = SecureTokenRepository(const PlatformSecureStorage());
  await tokenRepo.loadToken();

  FirebaseAuth.initialize(kFirestoreApiKey, ScureTokenStore(tokenRepo));
  Firestore.initialize(kFirestoreProjectId);
  await Connection.instance.initConnection();

  final networkService = NetworkService(Firestore.instance);

  runZonedGuarded(
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
              create: (_) => InfoBloc(FirebaseAuth.instance),
            ),
          ],
          child: Builder(
            builder: (context) => SuperBingo(),
          ),
        ),
      ),
    ),
    (error, stackTrace) {
      if (!kIsWeb) {
        Crashlytics.instance.recordError(error, stackTrace);
      }
    },
  );
}
