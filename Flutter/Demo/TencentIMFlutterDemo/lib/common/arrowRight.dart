import 'package:flutter/material.dart';

class ArrowRight extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.keyboard_arrow_right,
      color: Color(int.parse('111111', radix: 16)).withAlpha(255),
    );
  }
}
