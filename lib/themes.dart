import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Dark/Light Theme

class TheThemePreference {
  // ignore: constant_identifier_names
  static const THEME_STATUS = "THEMESTATUS";

  setDarkTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_STATUS, value);
  }

  Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_STATUS) ?? false;
  }
}

class TheThemeProvider with ChangeNotifier {
  TheThemePreference darkThemePreference = TheThemePreference();
  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    _darkTheme = value;
    darkThemePreference.setDarkTheme(value);
    notifyListeners();
  }
}

// Color Theme

class TheColorThemePreference {
  // ignore: constant_identifier_names
  static const THEME_COLOR = "THEMECOLOR";

  setThemeColor(int color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(THEME_COLOR, color);
  }

  Future<int> getThemeColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(THEME_COLOR) ?? 0;
  }
}

class ThemeColorProvider with ChangeNotifier {
  TheColorThemePreference colorThemePreference = TheColorThemePreference();
  int _colorTheme = 0;

  int get colorTheme => _colorTheme;

  set colorTheme(int color) {
    _colorTheme = color;
    colorThemePreference.setThemeColor(color);
    notifyListeners();
  }
}
