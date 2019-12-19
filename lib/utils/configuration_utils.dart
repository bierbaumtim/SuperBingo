import 'package:shared_preferences/shared_preferences.dart';

Future<String> getUsername() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('playername') ?? '';
}
