import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/src/chat.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

class GroupList extends StatelessWidget {
  final sdkInstance = TIMUIKitCore.getSDKInstance();

  GroupList({Key? key}) : super(key: key);

  _jumpToChatPage(BuildContext context, String groupId) async {
    final res = await sdkInstance
        .getConversationManager()
        .getConversation(conversationID: "group_$groupId");
    if (res.code == 0) {
      final conversation = res.data;
      if (conversation != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Chat(selectedConversation: conversation),
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            imt("群聊"),
            style: TextStyle(color: Colors.black),
          ),
          shadowColor: Colors.white,
          backgroundColor: hexToColor("EBF0F6"),
          iconTheme: const IconThemeData(
            color: Colors.black,
          )),
      body: TIMUIKitGroup(
        onTapItem: (groupInfo) {
          final groupID = groupInfo.groupID;
          _jumpToChatPage(context, groupID);
        },
      ),
    );
  }
}
