import 'package:flutter/cupertino.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

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
