
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/permission.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitProfile/profile_widget.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitProfile/widget/tim_uikit_profile_widget.dart';
import 'package:tim_ui_kit/ui/widgets/toast.dart';
import 'package:tim_ui_kit_calling_plugin/enum/tim_uikit_trtc_calling_scence.dart';
import 'package:tim_ui_kit_calling_plugin/tim_ui_kit_calling_plugin.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:timuikit/src/search.dart';
import 'package:timuikit/utils/platform.dart';
import 'package:timuikit/utils/push/push_constant.dart';
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
  TUICalling? _calling;
  final V2TIMManager sdkInstance = TIMUIKitCore.getSDKInstance();
  String? newUserMARK;

  _itemClick(
      String id, BuildContext context, V2TimConversation conversation) async {
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
        final user = await sdkInstance.getLoginUser();
        final myId = user.data;
        OfflinePushInfo offlinePush = OfflinePushInfo(
          title: "",
          desc: imt("邀请你语音通话"),
          ext: "{\"conversationID\": \"c2c_$myId\"}",
          disablePush: false,
          androidOPPOChannelID: PushConfig.OPPOChannelID,
          ignoreIOSBadge: false,
        );

         await Permissions.checkPermission(
            context, Permission.microphone.value);

        _calling?.call(widget.userID, CallingScenes.Audio, offlinePush);
        break;
      case "videoCall":
        final user = await sdkInstance.getLoginUser();
        final myId = user.data;
        OfflinePushInfo offlinePush = OfflinePushInfo(
          title: "",
          desc: imt("邀请你视频通话"),
          ext: "{\"conversationID\": \"c2c_$myId\"}",
          androidOPPOChannelID: PushConfig.OPPOChannelID,
          disablePush: false,
          ignoreIOSBadge: false,
        );

        await Permissions.checkPermission(context, Permission.camera.value);
        await Permissions.checkPermission(
            context, Permission.microphone.value);
            
        _calling?.call(widget.userID, CallingScenes.Video, offlinePush);
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

  handleTapRemarkBar(BuildContext context) async {
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

  _initTUICalling() async {
    final isAndroidEmulator = await PlatformUtils.isAndroidEmulator();
    if (!isAndroidEmulator) {
      _calling = TUICalling();
    }
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    _initTUICalling();
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
          profileWidgetBuilder: ProfileWidgetBuilder(
            searchBar: (conversation) => TIMUIKitProfileWidget.searchBar(context, conversation,
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
            customBuilderOne: (bool isFriend, V2TimFriendInfo friendInfo, V2TimConversation conversation){
              if(!isFriend){
                return Container();
              }
              return Column(
                  children: _buildBottomOperationList(
                  context, conversation, theme)
              );
            }
          ),
          controller: _timuiKitProfileController,
          profileWidgetsOrder: const [
            ProfileWidgetEnum.userInfoCard,
            ProfileWidgetEnum.operationDivider,
            ProfileWidgetEnum.remarkBar,
            ProfileWidgetEnum.genderBar,
            ProfileWidgetEnum.birthdayBar,
            ProfileWidgetEnum.operationDivider,
            ProfileWidgetEnum.searchBar,
            ProfileWidgetEnum.operationDivider,
            ProfileWidgetEnum.addToBlockListBar,
            ProfileWidgetEnum.pinConversationBar,
            ProfileWidgetEnum.messageMute,
            ProfileWidgetEnum.operationDivider,
            ProfileWidgetEnum.customBuilderOne,
            ProfileWidgetEnum.addAndDeleteArea
          ],
        ),
      ),
    );
  }
}
