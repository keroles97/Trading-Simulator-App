import 'package:app/constants/strings.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({
    Key? key,
    required this.size,
    required this.theme,
  }) : super(key: key);
  final Size size;
  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(
          strings['privacy_policy']!,
          style: TextStyle(
              color: theme.themeAccent,
              fontSize: size.height * 0.025,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          width: size.width * .8,
          height: size.height * .8,
          child: Center(
            child: SfPdfViewer.asset(
              "assets/pdf/privacy.pdf",
              onDocumentLoadFailed: (e) {
                print(e.error);
              },
            ),
          ),
        ));
  }
}
