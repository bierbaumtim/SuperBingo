import 'package:shared_preferences/shared_preferences.dart';

/// Liest den Name des Client-abhängigen Spielers aus und gibt diesen zurück
Future<String> getUsername() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('playername') ?? '';
}
