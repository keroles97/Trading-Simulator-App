import 'package:flutter/material.dart';

class GrayDivider extends StatelessWidget {
  const GrayDivider({Key? key, required this.size,}) : super(key: key);
  final Size size;

  @override
  Widget build(BuildContext context) {
    return  Container(
      margin: EdgeInsets.symmetric(vertical: size.height*.0),
      width: size.width,
      height: size.height*.0005,
      color: Colors.grey,
    );
  }
}
