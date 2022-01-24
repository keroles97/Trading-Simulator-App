import 'package:app/constants/strings.dart';
import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String textKey) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Text(strings[textKey]!),
      action:
          SnackBarAction(label: 'Ok', onPressed: scaffold.hideCurrentSnackBar),
    ),
  );
}
