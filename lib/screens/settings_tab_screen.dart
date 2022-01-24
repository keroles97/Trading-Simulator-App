import 'package:app/constants/strings.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/widgets/settings_button.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsTabScreen extends StatelessWidget {
  const SettingsTabScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    ThemeProvider themeProvider =
        Provider.of<ThemeProvider>(context, listen: true);
    return Stack(children: [
      Positioned(
        top: size.height * 0.04,
        left: 1,
        right: 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                "assets/app_icons/launcher_icon.png",
                width: size.height * 0.17,
                height: size.height * 0.17,
                fit: BoxFit.cover,
              ),
            ),
            VerticalSpace(size: size, percentage: 0.01),
            Text(
              strings['app_name']!,
              style: TextStyle(
                  fontSize: size.height * 0.025, fontWeight: FontWeight.bold),
            ),
            VerticalSpace(size: size, percentage: 0.004),
            Text(
              "v1.0.0",
              style: TextStyle(
                  color: themeProvider.swapBackground(),
                  fontSize: size.height * 0.015),
            ),
          ],
        ),
      ),
      Positioned(
        left: 1,
        right: 1,
        bottom: size.height * 0.04,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SettingsButton(
                size: size,
                ctx: context,
                theme: themeProvider,
                textKey: "theme_color"),
            SettingsButton(
                size: size,
                ctx: context,
                theme: themeProvider,
                textKey: "theme_mode"),
            SettingsButton(
                size: size,
                ctx: context,
                theme: themeProvider,
                textKey: "privacy_policy"),
          ],
        ),
      )
    ]);
  }
}
