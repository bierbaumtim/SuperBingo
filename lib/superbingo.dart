import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_support/overlay_support.dart';

import 'bloc/blocs/info_bloc.dart';
import 'bloc/states/info_states.dart';
import 'pages/game_page.dart';
import 'pages/join_game_page.dart';
import 'pages/new_game_page.dart';
import 'pages/player_page.dart';
import 'pages/start.dart';

class SuperBingo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        themeMode: ThemeMode.light,
        theme: lightTheme,
        // showPerformanceOverlay: true,
        home: BlocBuilder<InfoBloc, InfoState>(
          builder: (context, state) {
            if (state is InfosLoaded) {
              return StartPage();
            } else if (state is InfosLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is FirstStart) {
              return PlayerPage();
            } else {
              return const Scaffold(
                body: Center(
                  child: Text('Test'),
                ),
              );
            }
          },
        ),
        routes: {
          '/new_game': (context) => NewGamePage(),
          '/join_game': (context) => JoinGamePage(),
          '/game': (context) => GamePage(),
          '/user_page': (context) => PlayerPage(),
        },
      ),
    );
  }
}

/// Theme der App
ThemeData get lightTheme => ThemeData.dark().copyWith(
      // scaffoldBackgroundColor: Colors.deepOrangeAccent,
      // primaryColor: Colors.deepOrangeAccent,
      accentColor: Colors.deepOrange,
      primaryTextTheme: basicTextTheme,
      textTheme: basicTextTheme,
      appBarTheme: const AppBarTheme(elevation: 0),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.deepOrange,
        textTheme: ButtonTextTheme.normal,
      ),
      buttonColor: Colors.deepOrange,
      cardTheme: CardTheme(
        color: Colors.grey[700],
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
    );

/// TextTheme mit Georgia als FontFamily
TextTheme get basicTextTheme => TextTheme(
      bodyText1: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      bodyText2: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      caption: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      button: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      subtitle2: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      overline: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headline6: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      subtitle1: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headline5: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headline4: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 34,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headline3: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headline2: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 56,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headline1: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 112,
        fontWeight: FontWeight.w100,
        letterSpacing: 0,
      ),
    );
