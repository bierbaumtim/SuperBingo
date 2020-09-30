import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Liest den Name des Client-abhängigen Spielers aus und gibt diesen zurück
Future<String> getUsername() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('playername') ?? '';
}

bool get isDesktop {
  if (kIsWeb) return false;
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}

bool get isWindows {
  if (kIsWeb) return false;
  return Platform.isWindows;
}
