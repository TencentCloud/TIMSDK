import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/widgets/toast.dart';
import 'package:tim_ui_kit_calling_plugin/enum/tim_uikit_trtc_calling_scence.dart';
import 'package:tim_ui_kit_calling_plugin/tim_ui_kit_calling_plugin.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:timuikit/src/search.dart';

import '../utils/toast.dart';
import 'chat.dart';

class UserProfile extends StatefulWidget {
  final String userID;
  const UserProfile({Key? key, required this.userID}) : super(key: key);
  @override
  State<StatefulWidget> createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  final TIMUIKitProfileController _timuiKitProfileController =
      TIMUIKitProfileController();
  final TUICalling _calling = TUICalling();
  String? newUserMARK;

  _itemClick(String id, BuildContext context, V2TimConversation conversation) {
    switch (id) {
      case "sendMsg":
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Chat(
                selectedConversation: conversation,
              ),
            ));
        break;
      case "deleteFriend":
        _timuiKitProfileController.deleteFriend(widget.userID).then((res) {
          if (res == null) {
            throw Error();
          }
          if (res.resultCode == 0) {
            Toast.showToast(ToastType.success, imt("好友删除成功"), context);
            _timuiKitProfileController.loadData(widget.userID);
          } else {
            throw Error();
          }
        }).catchError((error) {
          Toast.showToast(ToastType.fail, imt("好友添加失败"), context);
        });
        break;
      case "audioCall":
        _calling.call(widget.userID, CallingScenes.Audio);
        break;
      case "videoCall":
        _calling.call(widget.userID, CallingScenes.Video);
        break;
    }
  }

  _buildBottomOperationList(
      BuildContext context, V2TimConversation conversation, theme) {
    final operationList = [
      {
        "label": imt("发送消息"),
        "id": "sendMsg",
      },
      {
        "label": imt("语音通话"),
        "id": "audioCall",
      },
      {
        "label": imt("视频通话"),
        "id": "videoCall",
      },
      {
        "label": imt("清除好友"),
        "id": "deleteFriend",
      }
    ];

    return operationList.map((e) {
      return InkWell(
        onTap: () {
          _itemClick(e["id"] ?? "", context, conversation);
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border(bottom: BorderSide(color: theme.weakDividerColor))),
          child: Text(
            e["label"] ?? "",
            style: TextStyle(
                color: e["id"] != "deleteFriend"
                    ? theme.primaryColor
                    : theme.cautionColor,
                fontSize: 17),
          ),
        ),
      );
    }).toList();
  }

  _addFriend(BuildContext context) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Utils.toast("无网络连接，无法修改");
      return;
    }
    _timuiKitProfileController.addFriend(widget.userID).then((res) {
      if (res == null) {
        throw Error();
      }
      if (res.resultCode == 0) {
        Toast.showToast(ToastType.success, imt("好友添加成功"), context);
        _timuiKitProfileController.loadData(widget.userID);
      } else if (res.resultCode == 30539) {
        Toast.showToast(ToastType.success, imt("好友申请已发出"), context);
      } else if (res.resultCode == 30515) {
        // sdkInstance
        //     .getFriendshipManager()
        //     .deleteFromBlackList(userIDList: [userID]);
        Toast.showToast(ToastType.fail, imt("当前用户在黑名单"), context);
      } else {
        throw Error();
      }
    }).catchError((error) {
      Toast.showToast(ToastType.fail, imt("好友添加失败"), context);
    });
  }

  handleTapRemarkBar(BuildContext context) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Utils.toast("无网络连接，无法修改");
      return;
    }
    _timuiKitProfileController.showTextInputBottomSheet(
        context, imt("修改备注"), imt("支持数字、英文、下划线"), (String remark) {
      newUserMARK = remark;
      _timuiKitProfileController.updateRemarks(widget.userID, remark);
    });
  }

  handleTapSearch(BuildContext context) async {
    _timuiKitProfileController.showTextInputBottomSheet(
        context, imt("修改备注"), imt("支持数字、英文、下划线"), (String remark) {
      newUserMARK = remark;
      _timuiKitProfileController.updateRemarks(widget.userID, remark);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.white,
        title: Text(
          imt("详细资料"),
          style: const TextStyle(color: Colors.white, fontSize: 17),
        ),
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
        ),
        leading: IconButton(
          padding: const EdgeInsets.only(left: 16),
          icon: Image.asset(
            'images/arrow_back.png',
            package: 'tim_ui_kit',
            height: 34,
            width: 34,
          ),
          onPressed: () {
            Navigator.pop(context, newUserMARK);
          },
        ),
      ),
      body: Container(
        color: theme.weakBackgroundColor,
        child: TIMUIKitProfile(
          userID: widget.userID,
          controller: _timuiKitProfileController,
          operationListBuilder:
              (context, friendInfo, conversation, friendType, isDisturb) {
            final remark = friendInfo.friendRemark ?? imt("无");
            final isPined = conversation.isPinned ?? false;
            final userID = friendInfo.userID;
            final conversationId = conversation.conversationID;
            return friendType != 0
                ? Column(
                    children: [
                      TIMUIKitProfile.operationDivider(),
                      TIMUIKitProfile.remarkBar(remark, context,
                          handleTap: () => handleTapRemarkBar(context)),
                      TIMUIKitProfile.searchBar(context, conversation,
                          handleTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Search(
                                  conversation: conversation,
                                  onTapConversation:
                                      (V2TimConversation conversation,
                                          [V2TimMessage? targetMsg]) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Chat(
                                            selectedConversation: conversation,
                                            initFindingMsg: targetMsg,
                                          ),
                                        ));
                                  }),
                            ));
                      }),
                      TIMUIKitProfile.operationDivider(),
                      TIMUIKitProfile.addToBlackListBar(false, context,
                          (value) async {
                        final connectivityResult =
                            await (Connectivity().checkConnectivity());
                        if (connectivityResult == ConnectivityResult.none) {
                          Utils.toast("无网络连接，无法修改");
                          return;
                        }
                        _timuiKitProfileController.addUserToBlackList(
                            value, userID);
                      }),
                      TIMUIKitProfile.operationDivider(),
                      TIMUIKitProfile.pinConversationBar(isPined, context,
                          (value) async {
                        final connectivityResult =
                            await (Connectivity().checkConnectivity());
                        if (connectivityResult == ConnectivityResult.none) {
                          Utils.toast("无网络连接，无法修改");
                          return;
                        }
                        _timuiKitProfileController.pinedConversation(
                            value, conversationId);
                      }),
                      TIMUIKitProfile.messageDisturb(context, isDisturb,
                          (value) async {
                        final connectivityResult =
                            await (Connectivity().checkConnectivity());
                        if (connectivityResult == ConnectivityResult.none) {
                          Utils.toast("无网络连接，无法修改");
                          return;
                        }
                        _timuiKitProfileController.setMessageDisturb(
                            userID, value);
                      }),
                      TIMUIKitProfile.operationDivider(),
                    ],
                  )
                : Column(
                    children: [
                      TIMUIKitProfile.operationDivider(),
                      Container(
                        alignment: Alignment.center,
                        // padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                bottom: BorderSide(
                                    color: theme.weakDividerColor ??
                                        CommonColor.weakDividerColor))),
                        child: Row(children: [
                          Expanded(
                            child: TextButton(
                                child: Text(imt("加为好友"),
                                    style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: 17)),
                                onPressed: () {
                                  _addFriend(context);
                                }),
                          )
                        ]),
                      )
                    ],
                  );
          },
          bottomOperationBuilder:
              (context, friendInfo, conversation, friendType) {
            return friendType != 0
                ? Column(
                    children: _buildBottomOperationList(
                        context, conversation!, theme))
                : Container();
          },
        ),
      ),
    );
  }
}
