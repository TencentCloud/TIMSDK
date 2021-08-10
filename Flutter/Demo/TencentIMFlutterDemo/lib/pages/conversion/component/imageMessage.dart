import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class ImageMessage extends StatelessWidget {
  final V2TimMessage message;
  ImageMessage(this.message);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: message.imageElem!.imageList!.map(
        (e) {
          if (e!.type == 2) {
            if (e.url != null) {
              return Image.network(
                e.url!,
                errorBuilder: (context, error, stackTrace) => LoadingIndicator(
                  indicatorType: Indicator.lineSpinFadeLoader,
                  color: Colors.black26,
                ),
              );
            } else {
              return Image.file(new File(message.imageElem!.path!));
            }
          } else {
            return Container();
          }
        },
      ).toList(),
    );
  }
}
