import 'package:flutter/material.dart';

typedef WebEvent = void Function(String name, String body);

class TIMWebView extends StatelessWidget {
  final String initialUrl;
  final double? width;
  final double? height;
  final WebEvent webEventHandler;

  const TIMWebView(
      {Key? key,
      required this.initialUrl,
      this.width,
      this.height,
      required this.webEventHandler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
