import 'package:app/constants/strings.dart';
import 'package:flutter/material.dart';

void showInfoAlertDialog(BuildContext context, String message, bool isError) {
  showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            title: Text(isError ? strings['error_occurred']! : strings['succeed']!),
            content: Text(message),
            actions: [
              TextButton(
                child: Text(strings['ok']!),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ));
}
