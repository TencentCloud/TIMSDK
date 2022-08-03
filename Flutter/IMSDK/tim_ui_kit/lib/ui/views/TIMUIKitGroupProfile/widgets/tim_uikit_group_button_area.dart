import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_group_profile_model.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_chat_controller.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';

class GroupProfileButtonArea extends TIMUIKitStatelessWidget {
  final String groupID;
  final TUIGroupProfileModel model;
  final sdkInstance = TIMUIKitCore.getSDKInstance();
  final coreInstance = TIMUIKitCore.getInstance();
  final TIMUIKitChatController _timuiKitChatController =
      TIMUIKitChatController();

  GroupProfileButtonArea(this.groupID, this.model, {Key? key})
      : super(key: key);

  final _operationList = [
    {"label": TIM_t("清空聊天记录"), "id": "clearHistory"},
    {"label": TIM_t("转让群主"), "id": "transimitOwner"},
    {"label": TIM_t("删除并退出"), "id": "quitGroup"},
    {"label": TIM_t("解散该群"), "id": "dismissGroup"}
  ];

  _clearHistory(BuildContext context, theme) async {
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
            child: Text(TIM_t("取消")),
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
                if (res.code == 0) {
                  _timuiKitChatController.clearHistory();
                }
              },
              child: Text(
                TIM_t("清空聊天记录"),
                style: TextStyle(color: theme.cautionColor),
              ),
              isDefaultAction: false,
            )
          ],
        );
      },
    );
  }

  _quitGroup(BuildContext context, theme) async {
    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(TIM_t("退出后不会接收到此群聊消息")),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
            child: Text(TIM_t("取消")),
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
                  if (deleteConvRes.code == 0) {
                    model.lifeCycle?.didLeaveGroup();
                  }
                }
                model.loadData(groupID);
              },
              child: Text(
                TIM_t("确定"),
                style: TextStyle(color: theme.cautionColor),
              ),
              isDefaultAction: false,
            )
          ],
        );
      },
    );
  }

  _dismissGroup(BuildContext context, theme) async {
    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(TIM_t("解散后不会接收到此群聊消息")),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
            child: Text(TIM_t("取消")),
            isDefaultAction: false,
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(
                  context,
                );
                final res = await sdkInstance.dismissGroup(groupID: groupID);
                if (res.code == 0) {
                  await sdkInstance
                      .getConversationManager()
                      .deleteConversation(conversationID: "group_$groupID");
                  model.lifeCycle?.didLeaveGroup();
                  model.loadData(groupID);
                }
              },
              child: Text(
                TIM_t("确定"),
                style: TextStyle(color: theme.cautionColor),
              ),
              isDefaultAction: false,
            )
          ],
        );
      },
    );
  }

  _transimitOwner(BuildContext context, String groupID) async {
    List<V2TimGroupMemberFullInfo>? selectedMember = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectTransimitOwner(
          model: model,
          groupID: groupID,
        ),
      ),
    );
    if (selectedMember != null) {
      final userID = selectedMember.first.userID;
      await sdkInstance
          .getGroupManager()
          .transferGroupOwner(groupID: groupID, userID: userID);
    }
  }

  List<Widget> _renderGroupOperation(
      BuildContext context, TUITheme theme, bool isOwner, String groupType) {
    return _operationList
        .where((element) {
          if (!isOwner) {
            return ["quitGroup", "clearHistory"].contains(element["id"]);
          } else {
            if (groupType == "Work") {
              return ["clearHistory", "quitGroup", "transimitOwner"]
                  .contains(element["id"]);
            }
            if (groupType != "Work") {
              return ["clearHistory", "dismissGroup", "transimitOwner"]
                  .contains(element["id"]);
            }
            return true;
          }
        })
        .map((e) => InkWell(
              onTap: () {
                if (e["id"]! == "clearHistory") {
                  _clearHistory(context, theme);
                } else if (e["id"] == "quitGroup") {
                  _quitGroup(context, theme);
                } else if (e["id"] == "dismissGroup") {
                  _dismissGroup(context, theme);
                } else if (e["id"] == "transimitOwner") {
                  _transimitOwner(context, groupID);
                }
              },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom: BorderSide(
                            color: theme.weakDividerColor ??
                                CommonColor.weakDividerColor))),
                child: Text(
                  e["label"]!,
                  style: TextStyle(color: theme.cautionColor, fontSize: 17),
                ),
              ),
            ))
        .toList();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final theme = value.theme;
    final groupInfo = model.groupInfo;
    return Column(
      children: [
        ..._renderGroupOperation(
            context,
            theme,
            groupInfo?.owner == coreInstance.loginUserInfo?.userID,
            groupInfo?.groupType ?? "")
      ],
    );
  }
}
