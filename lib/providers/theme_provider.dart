import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  String themeMode = "dark";
  int themeColor = Colors.orangeAccent.value;
  Color themeAccent = Colors.orangeAccent;
  Color lightBackground = const Color(0xFFF6F6F6);
  Color darkBackground = const Color(0xFF1D1D1D);

  setThemeMode(String themeMode) async {
    this.themeMode = themeMode;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("theme_mode", themeMode);
  }

  setThemeColor(Color themeColor) async {
    this.themeColor = themeColor.value;
    themeAccent = Color(this.themeColor);
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("theme_color", this.themeColor);
  }

  Color swapBackground() {
    switch (themeMode) {
      case "light":
        return Colors.black;
      case "dark":
        return Colors.white;
      default:
        return Colors.black;
    }
  }

  Color getBackground() {
    switch (themeMode) {
      case "light":
        return lightBackground;
      case "dark":
        return darkBackground;
      default:
        return darkBackground;
    }
  }

  ThemeMode getTheme() {
    switch (themeMode) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      default:
        return ThemeMode.dark;
    }
  }

  Future<void> loadThemePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    themeMode = prefs.getString("theme_mode") ?? "dark";
    themeColor = prefs.getInt("theme_color") ?? Colors.orangeAccent.value;
    themeAccent = Color(themeColor);
  }

  MaterialColor primarySwitch() {
    return MaterialColor(themeColor, <int, Color>{
      50: themeAccent,
      100: themeAccent,
      200: themeAccent,
      300: themeAccent,
      350: themeAccent,
      400: themeAccent,
      500: themeAccent,
      600: themeAccent,
      700: themeAccent,
      800: themeAccent,
      850: themeAccent,
      900: themeAccent,
    });
  }

  TextTheme textTheme() {
    return TextTheme(
      headline1: TextStyle(color: swapBackground()),
      headline2: TextStyle(color: swapBackground()),
      headline3: TextStyle(color: swapBackground()),
      headline4: TextStyle(color: swapBackground()),
      headline5: TextStyle(color: swapBackground()),
      headline6: TextStyle(color: swapBackground()),
      subtitle1: TextStyle(color: swapBackground()),
      subtitle2: TextStyle(color: swapBackground()),
      bodyText1: TextStyle(color: swapBackground()),
      bodyText2: TextStyle(color: swapBackground()),
    );
  }

}
