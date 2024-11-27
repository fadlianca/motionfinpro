import 'package:flutter/material.dart';
import 'light_mode.dart';
import 'dark_mode.dart';

class ThemeProvider extends ChangeNotifier {
  //inisialisasi lightmode
  ThemeData _themeData = darkMode;

  //mendapatkan themedata yg skrg
  ThemeData get themeData => _themeData;

  //theme yang sekarang
  bool get isLightMode => _themeData == lightMode;

  //set theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  //toggle theme
  void toggleTheme() {
    if (_themeData == darkMode) {
      themeData = lightMode;
    } else {
      themeData = darkMode;
    }
  }
}
