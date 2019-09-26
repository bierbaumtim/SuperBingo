import 'dart:async';

import 'package:flutter/material.dart';

import 'package:superbingo/blocs/game_bloc.dart';
import 'package:superbingo/blocs/open_games_bloc.dart';
import 'package:superbingo/superbingo.dart';
import 'package:superbingo/utils/stack.dart' as s;

import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  s.Stack test = s.Stack()..addAll([1, 2, 3, 4, 5, 6, 7, 8]);
  print(test);
  final testList = test.toList();
  print(testList);
  test = s.Stack.from([...testList, 9]);
  print(test);

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
