

import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:provider/provider.dart';

class Search extends StatelessWidget {
  const Search(
      {Key? key,
      this.conversation,
      required this.onTapConversation,
      this.initKeyword})
      : super(key: key);

  /// if assign a specific conversation, it will only search in it; otherwise search globally
  final V2TimConversation? conversation;

  /// the callback after clicking the conversation item to specific message in it
  final Function(V2TimConversation, V2TimMessage?) onTapConversation;

  /// initial keyword for detail search
  final String? initKeyword;

  @override
  Widget build(BuildContext context) {
    final isConversation = (conversation != null);

    final theme = Provider.of<DefaultThemeData>(context).theme;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        elevation: 0,
        backgroundColor: theme.primaryColor,
        title: Text(
          isConversation
              ? (conversation?.showName ??
                  conversation?.conversationID ??
                  imt("相关聊天记录"))
              : imt("全局搜索"),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),
        ),
      ),
      body: isConversation
          ? TIMUIKitSearchMsgDetail(
              currentConversation: conversation!,
              onTapConversation: onTapConversation,
              keyword: initKeyword ?? "",
            )
          : TIMUIKitSearch(
              onEnterConversation:
                  (V2TimConversation conversation, String keyword) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Search(
                        onTapConversation: onTapConversation,
                        conversation: conversation,
                        initKeyword: keyword,
                      ),
                    ));
              },
              onTapConversation: onTapConversation,
              conversation: conversation,
            ),
    );
  }
}
