import 'dart:convert';
import 'dart:html';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

typedef WebEvent = void Function(String name, Map body);

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
    final String boxWidth = (width ?? 360.0).toString();
    final String boxHeight = (height ?? 360.0).toString();
    window.document.onContextMenu.listen((evt) => evt.preventDefault());

    IFrameElement frame = IFrameElement()
      ..width = boxWidth
      ..id = "tencent-im-iframe"
      ..height = boxHeight
      ..src = initialUrl
      ..style.border = 'none';

    window.onMessage.forEach((element) {
      final messageObj = jsonDecode(element.data);
      webEventHandler(messageObj["name"], messageObj);
    });

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry
        .registerViewFactory('tencent-im-html', (int viewId) => frame);

    return const HtmlElementView(viewType: 'tencent-im-html');
  }
}
