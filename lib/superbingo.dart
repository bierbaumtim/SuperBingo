import 'package:flutter/material.dart';

import 'package:superbingo/pages/game_page.dart';
import 'package:superbingo/pages/join_game_page.dart';
import 'package:superbingo/pages/new_game_page.dart';
import 'package:superbingo/pages/player_page.dart';
import 'package:superbingo/pages/start.dart';

import 'package:overlay_support/overlay_support.dart';

class SuperBingo extends StatefulWidget {
  @override
  _SuperBingoState createState() => _SuperBingoState();
}

class _SuperBingoState extends State<SuperBingo> {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        themeMode: ThemeMode.light,
        theme: lightTheme,
        home: StartPage(),
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

ThemeData get lightTheme => ThemeData.dark().copyWith(
      // scaffoldBackgroundColor: Colors.deepOrangeAccent,
      // primaryColor: Colors.deepOrangeAccent,
      accentColor: Colors.deepOrange,
      primaryTextTheme: basicTextTheme,
      textTheme: basicTextTheme,
      appBarTheme: AppBarTheme(elevation: 0),
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

TextTheme get basicTextTheme => TextTheme(
      body1: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      body2: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 14,
        fontWeight: FontWeight.w500,
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
      subtitle: TextStyle(
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
      title: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      subhead: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      headline: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      display1: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 34,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      display2: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      display3: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 56,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
      display4: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 112,
        fontWeight: FontWeight.w100,
        letterSpacing: 0,
      ),
    );
