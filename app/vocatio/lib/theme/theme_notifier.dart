import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _highContrast = false;

  ThemeMode get themeMode => _themeMode;
  bool get isHighContrast => _highContrast;

  void setTheme(ThemeMode mode, {bool highContrast = false}){
    if(_themeMode != mode || _highContrast != highContrast){
      _themeMode = mode;
      _highContrast = highContrast;
      notifyListeners();
    }
  }
}