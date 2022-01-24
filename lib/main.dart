import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/database_provider.dart';
import 'package:app/providers/exchange_rate_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'constants/strings.dart';
import 'main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ChangeNotifierProxyProvider<AuthProvider, DatabaseProvider>(
          create: (_) => DatabaseProvider(),
          update: (ctx, auth, db) =>
              db!..getUserAuthData(auth.token, auth.uId)),
      ChangeNotifierProvider<ExchangeRateProvider>(create: (_) => ExchangeRateProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: true);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: strings["app_name"]!,
      themeMode: theme.getTheme(),
      theme: ThemeData(
        disabledColor: Colors.grey,
        hintColor: Colors.grey,
        primaryColor: theme.themeAccent,
        primarySwatch: theme.primarySwitch(),
        dialogBackgroundColor: theme.getBackground(),
        primaryIconTheme: IconThemeData(color: theme.themeAccent),
        unselectedWidgetColor: Colors.grey,
        canvasColor: theme.getBackground(),
        textTheme: theme.textTheme(),
      ),
      home: const MainPage(),
    );
  }
}
