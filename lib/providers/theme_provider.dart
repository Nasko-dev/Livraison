import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);

    notifyListeners();
  }

  // Pour la compatibilité avec les widgets Material et Cupertino
  Brightness get currentBrightness =>
      _isDarkMode ? Brightness.dark : Brightness.light;

  CupertinoThemeData get theme {
    return _isDarkMode
        ? const CupertinoThemeData(
            brightness: Brightness.dark,
            primaryColor: CupertinoColors.systemBlue,
            scaffoldBackgroundColor: CupertinoColors.black,
            barBackgroundColor: CupertinoColors.darkBackgroundGray,
            textTheme: CupertinoTextThemeData(
              textStyle: TextStyle(color: CupertinoColors.white),
            ),
          )
        : const CupertinoThemeData(
            brightness: Brightness.light,
            primaryColor: CupertinoColors.systemBlue,
            scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
            barBackgroundColor: CupertinoColors.systemBackground,
            textTheme: CupertinoTextThemeData(
              textStyle: TextStyle(color: CupertinoColors.black),
            ),
          );
  }
}
