import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/single_child_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'bloc/blocs/current_game_bloc.dart';
import 'bloc/blocs/game_configuration_bloc.dart';
import 'bloc/blocs/info_bloc.dart';
import 'bloc/blocs/interaction_bloc.dart';
import 'bloc/blocs/join_game_bloc.dart';
import 'bloc/blocs/open_games_bloc.dart';
import 'services/auth_service/auth_service_desktop.dart';
import 'services/auth_service/auth_service_mobile.dart';
import 'services/firebase_service.dart';
import 'services/log_service.dart';
import 'services/network_service/network_service_interface.dart';
import 'superbingo.dart';
import 'utils/configuration_utils.dart';
import 'utils/connection.dart';

/// ignore: avoid_void_async
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseService.instance.initFirebase();

  FlutterError.onError = LogService.instance.recordFlutterError;
  await Connection.instance.initConnection();

  runZonedGuarded(
    () => runApp(
      MultiProvider(
        providers: <SingleChildWidget>[
          Provider<PublicGamesBloc>(
            create: (_) => PublicGamesBloc(),
            dispose: (_, bloc) => bloc.dispose(),
          ),
          Provider<INetworkService>(
            create: (_) => FirebaseService.instance.networkService,
            dispose: (_, service) => service.dispose(),
            lazy: false,
          ),
        ],
        child: MultiBlocProvider(
          providers: <BlocProvider>[
            BlocProvider<GameConfigurationBloc>(
              create: (context) => GameConfigurationBloc(
                context.read<INetworkService>(),
              ),
            ),
            BlocProvider<JoinGameBloc>(
              create: (context) => JoinGameBloc(
                context.read<INetworkService>(),
              ),
            ),
            BlocProvider<CurrentGameBloc>(
              create: (context) => CurrentGameBloc(
                context.read<INetworkService>(),
              ),
            ),
            BlocProvider<InteractionBloc>(
              create: (context) => InteractionBloc(
                context.read<INetworkService>(),
              ),
            ),
            BlocProvider<InfoBloc>(
              create: (_) => InfoBloc(
                isDesktop ? AuthServiceDesktop() : AuthServiceMobile(),
              ),
            ),
          ],
          child: SuperBingo(),
        ),
      ),
    ),
    LogService.instance.recordError,
  );
}
