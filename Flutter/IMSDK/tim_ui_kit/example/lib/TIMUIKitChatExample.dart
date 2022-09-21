// ignore_for_file: file_names

import 'package:example/TIMUIKitGroupProfileExample.dart';
import 'package:example/TIMUIKitProfileExample.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

class TIMUIKitChatExample extends StatelessWidget {
  final V2TimConversation? selectedConversation;

  const TIMUIKitChatExample({Key? key, this.selectedConversation})
      : super(key: key);

  String? _getConversationID() {
    if(selectedConversation != null){
      return selectedConversation!.type == 1
          ? selectedConversation!.userID
          : selectedConversation!.groupID;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TIMUIKitChat(
      config: const TIMUIKitChatConfig(
        // 仅供演示，非全部配置项，实际使用中，可只传和默认项不同的参数，无需传入所有开关
        isAllowClickAvatar: true,
        isAllowLongPressMessage: true,
        isShowReadingStatus: true,
        isShowGroupReadingStatus: true,
        notificationTitle: "",
        isUseMessageReaction: true,
        groupReadReceiptPermissionList: [
          GroupReceiptAllowType.work,
          GroupReceiptAllowType.meeting,
          GroupReceiptAllowType.public
        ],
      ),
      conversationID: _getConversationID() ??  "10040818",
      // Please fill in here according to the actual cleaning
      conversationShowName: selectedConversation?.showName ??
          selectedConversation?.userID ??
          selectedConversation?.groupID ??
          "Test Chat",
      // Please fill in here according to the actual cleaning
      conversationType: ConvType.values[selectedConversation?.type ?? 1],
        appBarConfig: AppBar(
          actions: [
          IconButton(
              padding: const EdgeInsets.only(left: 8, right: 16),
              onPressed: () async {
                final conversationType = selectedConversation?.type ?? 1;

                if (conversationType == 1) {
                  final String? userID = selectedConversation?.userID;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: Text(userID ?? "User Profile")),
                            body: TIMUIKitProfileExample(userID: userID)),
                      ));
                } else {
                  final String? groupID = selectedConversation?.groupID;
                  if (groupID != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                              appBar: AppBar(title: Text(groupID)),
                              body: TIMUIKitGroupProfileExample(
                            groupID: groupID,
                          )),
                        ));
                  }
                }
              },
              icon: Image.asset(
                'images/more.png',
                package: 'tim_ui_kit',
                  height: 34,
                  width: 34,
                ))
          ],
        ),
    );
  }
}
