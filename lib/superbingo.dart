import 'package:flutter/material.dart';

import 'package:overlay_support/overlay_support.dart';

// import 'pages/desktop_game_page_debug.dart';
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
        themeMode: ThemeMode.dark,
        theme: darkTheme,
        // showPerformanceOverlay: true,
        home: StartPage(),
        routes: {
          '/new_game': (context) => NewGamePage(),
          '/join_game': (context) => JoinGamePage(),
          '/game': (context) => GamePage(),
          '/user_page': (context) => PlayerPage(),
          // '/desktop_game_page_debug': (context) => DesktopGamePageDebug(),
        },
      ),
    );
  }
}

/// Theme der App
ThemeData get darkTheme => ThemeData.dark().copyWith(
      // scaffoldBackgroundColor: Colors.deepOrangeAccent,
      // primaryColor: Colors.deepOrangeAccent,
      accentColor: Colors.deepOrange,
      primaryTextTheme: basicTextTheme,
      textTheme: basicTextTheme,
      appBarTheme: const AppBarTheme(elevation: 0),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.deepOrange,
      ),
      buttonColor: Colors.deepOrange,
      cardTheme: CardTheme(
        color: Colors.grey[700],
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
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
