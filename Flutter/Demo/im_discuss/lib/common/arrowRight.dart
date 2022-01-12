import 'package:discuss/common/hextocolor.dart';
import 'package:flutter/material.dart';

class ArrowRight extends StatelessWidget {
  const ArrowRight({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.keyboard_arrow_right,
      color: hexToColor("111111"),
    );
  }
}
