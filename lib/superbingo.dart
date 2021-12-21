import 'package:flutter/material.dart';

import 'package:overlay_support/overlay_support.dart';

import 'pages/game_page.dart';
import 'pages/join_game_page.dart';
import 'pages/new_game_page.dart';
import 'pages/player_page.dart';
import 'pages/start.dart';

class SuperBingo extends StatelessWidget {
  const SuperBingo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        theme: darkTheme,
        // showPerformanceOverlay: true,
        home: const StartPage(),
        routes: {
          '/new_game': (context) => const NewGamePage(),
          '/join_game': (context) => const JoinGamePage(),
          '/game': (context) => const GamePage(),
          '/user_page': (context) => const PlayerPage(),
        },
      ),
    );
  }
}

/// Theme der App
ThemeData get darkTheme => ThemeData.dark().copyWith(
      // scaffoldBackgroundColor: Colors.deepOrangeAccent,
      // primaryColor: Colors.deepOrangeAccent,
      primaryTextTheme: basicTextTheme,
      textTheme: basicTextTheme,
      appBarTheme: const AppBarTheme(elevation: 0),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.deepOrange,
      ),
      cardTheme: CardTheme(
        color: Colors.grey[700],
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      colorScheme:
          const ColorScheme.dark().copyWith(secondary: Colors.deepOrange),
    );

/// TextTheme mit Georgia als FontFamily
TextTheme get basicTextTheme => const TextTheme(
      bodyText1: TextStyle(
        color: Colors.white,
        fontFamily: 'Georgia',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      bodyText2: TextStyle(
        color: Colors.white,
        fontFamily: 'Georgia',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      caption: TextStyle(
        color: Colors.white,
        fontFamily: 'Georgia',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      button: TextStyle(
        color: Colors.white,
        fontFamily: 'Georgia',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      subtitle2: TextStyle(
        color: Colors.white,
        fontFamily: 'Georgia',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      overline: TextStyle(
        color: Colors.white,
        fontFamily: 'Georgia',
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headline6: TextStyle(
        color: Colors.white,
        fontFamily: 'Georgia',
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      subtitle1: TextStyle(
        color: Colors.white,
        fontFamily: 'Georgia',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headline5: TextStyle(
        color: Colors.white,
        fontFamily: 'Georgia',
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headline4: TextStyle(
        color: Colors.white,
        fontFamily: 'Georgia',
        fontSize: 34,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headline3: TextStyle(
        color: Colors.white,
        fontFamily: 'Georgia',
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headline2: TextStyle(
        color: Colors.white,
        fontFamily: 'Georgia',
        fontSize: 56,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headline1: TextStyle(
        color: Colors.white,
        fontFamily: 'Georgia',
        fontSize: 112,
        fontWeight: FontWeight.w100,
        letterSpacing: 0,
      ),
    );
