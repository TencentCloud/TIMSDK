import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_chat_controller.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timuikit/src/pages/home_page.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

class GroupProfilePage extends StatelessWidget {
  final String groupID;
  final sdkInstance = TIMUIKitCore.getSDKInstance();
  GroupProfilePage({Key? key, required this.groupID}) : super(key: key);
  final TIMUIKitChatController _timuiKitChatController =
      TIMUIKitChatController();

  final _operationList = [
    {"label": imt("清空聊天记录"), "id": "clearHistory"},
    // {"label": imt("转让群主"), "id": "transimitOwner"},
    {"label": imt("删除并退出"), "id": "quitGroup"}
  ];

  _clearHistory(BuildContext context) async {
    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
            child: Text(imt("取消")),
            isDefaultAction: false,
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(
                  context,
                );
                final res = await sdkInstance
                    .getMessageManager()
                    .clearGroupHistoryMessage(groupID: groupID);
                Fluttertoast.showToast(
                  msg: res.desc,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  textColor: Colors.white,
                  backgroundColor: Colors.black,
                );
                if (res.code == 0) {
                  _timuiKitChatController.clearHistory();
                }
              },
              child: Text(
                imt("清空聊天记录"),
                style: TextStyle(color: hexToColor("FF584C")),
              ),
              isDefaultAction: false,
            )
          ],
        );
      },
    );
  }

  _quitGroup(BuildContext context) async {
    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(imt("退出后不会接收到此群聊消息")),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
            child: Text(imt("取消")),
            isDefaultAction: false,
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(
                  context,
                );
                final res = await sdkInstance.quitGroup(groupID: groupID);
                if (res.code == 0) {
                  final deleteConvRes = await sdkInstance
                      .getConversationManager()
                      .deleteConversation(conversationID: "group_$groupID");
                  Fluttertoast.showToast(
                    msg: deleteConvRes.desc,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    textColor: Colors.white,
                    backgroundColor: Colors.black,
                  );
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage(
                                pageIndex: 1,
                              )),
                      (route) => false);
                } else {
                  Fluttertoast.showToast(
                    msg: res.desc,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    textColor: Colors.white,
                    backgroundColor: Colors.black,
                  );
                }
              },
              child: Text(
                imt("确定"),
                style: TextStyle(color: hexToColor("FF584C")),
              ),
              isDefaultAction: false,
            )
          ],
        );
      },
    );
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
        body: TIMUIKitGroupProfile(
          groupID: groupID,
          operationListBuilder: (context, groupInfo, memberList) {
            return Column(
              children: [
                TIMUIKitGroupProfile.memberTile(),
                TIMUIKitGroupProfile.operationDivider(),
                TIMUIKitGroupProfile.groupNotification(),
                TIMUIKitGroupProfile.groupManage(),
                TIMUIKitGroupProfile.groupAddOpt(),
                TIMUIKitGroupProfile.groupType(),
                TIMUIKitGroupProfile.operationDivider(),
                TIMUIKitGroupProfile.nameCard()
              ],
            );
          },
          bottomOperationBuilder: (context) {
            return Container(
              margin: const EdgeInsets.only(top: 10),
              child: Column(
                children: _operationList
                    .map((e) => InkWell(
                          onTap: () {
                            if (e["id"]! == "clearHistory") {
                              _clearHistory(context);
                            } else if (e["id"] == "quitGroup") {
                              _quitGroup(context);
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                    bottom: BorderSide(
                                        color: hexToColor("E5E5E5")))),
                            child: Text(
                              e["label"]!,
                              style: TextStyle(
                                  color: hexToColor("FF584C"), fontSize: 17),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            );
          },
        ));
  }
}
