// ignore_for_file: avoid_print, file_names, unnecessary_import

import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/tim_uikit_search.dart';

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
