import 'package:shared_preferences/shared_preferences.dart';

class PreferenceKeys {
  static const String uri = "uri";
}

Future<List<String>> loadUriHistory() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> uri = prefs.getStringList(PreferenceKeys.uri) ?? [];
  return uri;
}

Future<void> saveUriHistory(List<String> uri) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(PreferenceKeys.uri, uri);
}
