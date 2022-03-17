import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/src/chat.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/src/provider/theme.dart';

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
    final theme = Provider.of<DefaultThemeData>(context).theme;
    return Scaffold(
      appBar: AppBar(
          title: Text(
            imt("群聊"),
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          shadowColor: Colors.white,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
                theme.primaryColor ?? CommonColor.primaryColor
              ]),
            ),
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
          )),
      body: TIMUIKitGroup(
        onTapItem: (groupInfo) {
          final groupID = groupInfo.groupID;
          _jumpToChatPage(context, groupID);
        },
        emptyBuilder: (_) {
          return Center(
            child: Text(imt("暂无群聊")),
          );
        },
        groupCollector: (groupInfo) {
          final groupID = groupInfo?.groupID ?? "";
          return !groupID.contains("im_discuss_");
        },
      ),
    );
  }
}
