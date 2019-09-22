import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superbingo/superbingo.dart';

void main() async {
  runApp(
    MultiProvider(
      child: SuperBingo(),
      providers: [],
    ),
  );
}
