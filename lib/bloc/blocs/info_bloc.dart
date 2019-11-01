import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfoBloc {
  BehaviorSubject<bool> _firstStartController;

  Sink<bool> get _firstStartSink => _firstStartController.sink;
  Stream<bool> get firstStartStream => _firstStartController.stream;

  InfoBloc() {
    _firstStartController = BehaviorSubject();
    SharedPreferences.getInstance().then((prefs) {
      final firstStart = prefs.getBool('firststart') ?? true;
      _firstStartSink.add(firstStart);
      if (firstStart) {
        prefs.setBool('firststart', false);
      }
    });
  }

  void firstStartCompleted() {
    _firstStartSink.add(false);
  }

  void dispose() {
    _firstStartController.close();
  }
}
