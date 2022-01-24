import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/screens/loading_screen.dart';
import 'package:app/screens/sign_in_sign_up_screen.dart';
import 'package:app/screens/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _themeLoaded = false;
  bool _authChecked = false;

  @override
  void initState() {
    Provider.of<ThemeProvider>(context, listen: false)
        .loadThemePrefs()
        .then((value) {
      setState(() {
        _themeLoaded = true;
      });
    });
    Provider.of<AuthProvider>(context, listen: false)
        .tryAutoSignIn()
        .then((value) {
      setState(() {
        _authChecked = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: true);
    return SafeArea(
        child: Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: _themeLoaded && _authChecked
            ? auth.isAuth
                ? const TabsScreen()
                : const SignInSignUpScreen()
            : const LoadingScreen(),
      ),
    ));
  }
}
