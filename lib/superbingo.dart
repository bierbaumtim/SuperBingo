import 'package:flutter/material.dart';
import 'package:superbingo/pages/start.dart';

class SuperBingo extends StatefulWidget {
  @override
  _SuperBingoState createState() => _SuperBingoState();
}

class _SuperBingoState extends State<SuperBingo> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.deepOrangeAccent,
      ),
      home: StartPage(),
    );
  }
}
