import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

class Conversation extends StatelessWidget {
  const Conversation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          imt("消息"),
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: TIMUIKitConversation(
        onTapItem: (selectedConv) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Chat(
                  selectedConversation: selectedConv,
                ),
              ));
        },
      ),
    );
  }
}

class Chat extends StatelessWidget {
  final V2TimConversation selectedConversation;
  const Chat({Key? key, required this.selectedConversation}) : super(key: key);
  String? _getConvID() {
    return selectedConversation.type == 1
        ? selectedConversation.userID
        : selectedConversation.groupID;
  }

  String _getTitle() {
    return selectedConversation.showName ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return TIMUIKitChat(
      conversationID: _getConvID() ?? '',
      conversationType: selectedConversation.type ?? 0,
      conversationShowName: _getTitle(),
      onTapAvatar: (_) {},
      appBarActions: [
        IconButton(
            onPressed: () {}, icon: const Icon(Icons.more_horiz_outlined))
      ],
    );
  }
}
