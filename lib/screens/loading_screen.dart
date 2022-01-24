import 'package:app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: true);
    return Container(
      color: theme.getBackground(),
      child: const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
