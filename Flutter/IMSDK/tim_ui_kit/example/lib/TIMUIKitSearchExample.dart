// ignore_for_file: avoid_print, file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

class TIMUIKitSearchExample extends StatelessWidget {
  const TIMUIKitSearchExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TIMUIKitSearch(
      onTapConversation: (conv, message) {
        print(conv.toJson());
        print(message!.toJson());
      },
      onEnterConversation: (V2TimConversation conversation, String keyword) {},
    );
  }
}
