import 'package:app/constants/strings.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';

class ThemeModeDialog extends StatelessWidget {
  const ThemeModeDialog({
    Key? key,
    required this.size,
    required this.themeProvider,
  }) : super(key: key);
  final Size size;
  final ThemeProvider themeProvider;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            child: Text(
              strings['light']!,
              style: TextStyle(
                  fontSize: size.height * 0.03, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            onPressed: () {
              themeProvider.setThemeMode("light");
              Navigator.of(context).pop(context);
            },
          ),
          VerticalSpace(size: size, percentage: 0.001),
          TextButton(
            child: Text(
              strings['dark']!,
              style: TextStyle(
                fontSize: size.height * 0.03,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            onPressed: () {
              themeProvider.setThemeMode("dark");
              Navigator.of(context).pop(context);
            },
          )
        ],
      ),
    ));
  }
}
