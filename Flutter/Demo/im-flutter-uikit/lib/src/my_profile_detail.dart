import 'dart:math';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_personal_profile_controller.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitProfile/widget/tim_uikit_profile_widget.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/src/config.dart';
import 'package:timuikit/src/provider/login_user_Info.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:provider/provider.dart';
import 'package:timuikit/utils/toast.dart';

class MyProfileDetail extends StatelessWidget {
  MyProfileDetail({Key? key}) : super(key: key);
  final CoreServicesImpl _coreServices = TIMUIKitCore.getInstance();
  final TIMUIKitPersonalProfileController _timUIKitPersonalProfileController =
      TIMUIKitPersonalProfileController();

  setRandomAvatar() async {
    int random = Random().nextInt(999);
    String avatar = "https://picsum.photos/id/$random/200/200";
    await _coreServices.setSelfInfo(
        userFullInfo: V2TimUserFullInfo.fromJson({
      "faceUrl": avatar,
    }));
  }

  showGenderChoseSheet(BuildContext context, TUITheme? theme) {
    showAdaptiveActionSheet(
      context: context,
      title: Text(imt("性别")),
      actions: <BottomSheetAction>[
        BottomSheetAction(
          title: Text(imt("男"), style: TextStyle(color: theme?.primaryColor)),
          onPressed: () {
            _timUIKitPersonalProfileController.updateGender(1);
            Navigator.pop(context);
          },
        ),
        BottomSheetAction(
          title: Text(imt("女"), style: TextStyle(color: theme?.primaryColor)),
          onPressed: () {
            _timUIKitPersonalProfileController.updateGender(2);
            Navigator.pop(context);
          },
        ),
      ],
      cancelAction: CancelAction(
        title: Text(imt("取消")),
      ), // onPressed parameter is optional by default will dismiss the ActionSheet
    );
  }

  String handleGender(int gender) {
    switch (gender) {
      case 0:
        return imt("未设置");
      case 1:
        return imt("男");
      case 2:
        return imt("女");
      default:
        return "";
    }
  }

  Future<bool?> showChangeAvatarDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(imt("TUIKIT 为你选择一个头像?")),
          actions: [
            CupertinoDialogAction(
              child: Text(imt("确定")),
              onPressed: () {
                setRandomAvatar();
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text(imt("取消")),
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showCantModify() {
    Utils.toast(imt("无网络连接，无法修改"));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    final loginUserInfoModel = Provider.of<LoginUserInfo>(context);
    final V2TimUserFullInfo loginUserInfo = loginUserInfoModel.loginUserInfo;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        shadowColor: theme.weakDividerColor,
        elevation: 1,
        title: Text(
          imt("个人资料"),
          style: const TextStyle(fontSize: IMDemoConfig.appBarTitleFontSize),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
              theme.primaryColor ?? CommonColor.primaryColor
            ]),
          ),
        ),
      ),
      body: Column(
        children: [
          GestureDetector(
            child: TIMUIKitOperationItem(
              operationName: TIM_t("头像"),
              operationRightWidget: SizedBox(
                width: 48,
                height: 48,
                child: Avatar(
                    faceUrl: loginUserInfo.faceUrl ?? "",
                    showName: loginUserInfo.nickName ?? ""),
              ),
            ),
            onTap: () => showChangeAvatarDialog(context),
          ),
          TIMUIKitProfileWidget.operationDivider(),
          GestureDetector(
            onTap: () async {
              _timUIKitPersonalProfileController.showTextInputBottomSheet(
                  context, imt("修改昵称"), imt("仅限中字、字母、数字和下划线"),
                  (String nickName) {
                _timUIKitPersonalProfileController.updateNickName(nickName);
              });
            },
            child: TIMUIKitOperationItem(
              operationName: TIM_t("昵称"),
              operationRightWidget: Text(loginUserInfo.nickName ?? ""),
            ),
          ),
          TIMUIKitProfileWidget.userAccountBar(
            loginUserInfo.userID ?? "",
          ),
          TIMUIKitProfileWidget.operationDivider(),
          GestureDetector(
            onTap: () async {
              _timUIKitPersonalProfileController.showTextInputBottomSheet(
                  context, imt("修改签名"), imt("仅限中字、字母、数字和下划线"),
                  (String selfSignature) {
                _timUIKitPersonalProfileController
                    .updateSelfSignature(selfSignature);
              });
            },
            child: TIMUIKitOperationItem(operationName: TIM_t("个性签名"),
              operationRightWidget: Text(loginUserInfo.selfSignature ?? imt("这个人很懒，什么也没写")))
          ),
          GestureDetector(
              onTap: () async {
                showGenderChoseSheet(context, theme);
              },
              child: TIMUIKitProfileWidget.genderBarWithArrow(loginUserInfo.gender ?? 0))
        ],
      ),
    );
  }
}
