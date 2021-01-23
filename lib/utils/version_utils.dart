import 'package:shared_preferences/shared_preferences.dart';

import 'package:superbingo/constants/version.dart';

Future<bool> get checkIfAppWasUpdated async {
  final prefs = await SharedPreferences.getInstance();
  final version = prefs.getString("version") ?? "";
  if (kAppVersion != version) {
    await prefs.setString("version", kAppVersion);
    return true;
  }
  return false;
}
