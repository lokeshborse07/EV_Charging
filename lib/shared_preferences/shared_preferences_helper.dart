import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  // Save theme to SharedPreferences
  static Future<void> saveTheme(String theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', theme);
  }

  // Get theme from SharedPreferences
  static Future<String?> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('theme') ?? 'Light'; // Default theme is Light
  }

  // Save language to SharedPreferences
  static Future<void> saveLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('language', language);
  }

  // Get language from SharedPreferences
  static Future<String?> getLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? 'English'; // Default language is English
  }
}
