import 'dart:math';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitProfile/widget/tim_uikit_profile_widget.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/src/config.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:provider/provider.dart';

class MyProfileDetail extends StatefulWidget {
  final V2TimUserFullInfo? userProfile;
  final TIMUIKitProfileController? controller;

  const MyProfileDetail({Key? key, this.userProfile, this.controller})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => MyProfileDetailState();

}

class MyProfileDetailState extends State<MyProfileDetail>{
  final CoreServicesImpl _coreServices = TIMUIKitCore.getInstance();
  late V2TimUserFullInfo? userProfile;

  @override
  void initState() {
    super.initState();
    userProfile = widget.userProfile;
  }

  final List<String> avatarURL = [
    "https://qcloudimg.tencent-cloud.cn/raw/3f574fd5dd7d3d253e23148f6dbb9d6c.png",
    "https://qcloudimg.tencent-cloud.cn/raw/9c6b6806f88ee33b3685f0435fe9a8b3.png",
    "https://qcloudimg.tencent-cloud.cn/raw/2c6e4177fcca03de1447a04d8ff76d9c.png",
    "https://qcloudimg.tencent-cloud.cn/raw/af98ae3d5c4094d2061612bea8fda4da.png",
    "https://qcloudimg.tencent-cloud.cn/raw/bd41d21551407655a01bba48894d33ad.png",
    "https://qcloudimg.tencent-cloud.cn/raw/f9b6638581718fefb101eaabf7f76a2e.png",
  ];

  setRandomAvatar() async {
    String avatar = avatarURL[Random().nextInt(6)];
    await _coreServices.setSelfInfo(
        userFullInfo: V2TimUserFullInfo.fromJson({
          "faceUrl": avatar,
        }));
    setState(() {
      userProfile?.faceUrl = avatar;
    });
  }

  showGenderChoseSheet(BuildContext context, TUITheme? theme) {
    showAdaptiveActionSheet(
      context: context,
      title: Text(imt("性别")),
      actions: <BottomSheetAction>[
        BottomSheetAction(
          title: Text(imt("男"), style: TextStyle(color: theme?.primaryColor)),
          onPressed: () async {
            final res = await widget.controller?.updateGender(1);
            if(res?.code == 0){
              setState(() {
                userProfile?.gender = 1;
              });
            }
            Navigator.pop(context);
          },
        ),
        BottomSheetAction(
          title: Text(imt("女"), style: TextStyle(color: theme?.primaryColor)),
          onPressed: () async {
            final res = await widget.controller?.updateGender(2);
            if(res?.code == 0){
              setState(() {
                userProfile?.gender = 2;
              });
            }
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
              child: Text(imt("取消")),
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text(imt("确定")),
              onPressed: () {
                setRandomAvatar();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
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
                    faceUrl: userProfile?.faceUrl ?? "",
                    showName: userProfile?.nickName ?? ""),
              ),
            ),
            onTap: () => showChangeAvatarDialog(context),
          ),
          TIMUIKitProfileWidget.operationDivider(),
          GestureDetector(
            onTap: () async {
              widget.controller?.showTextInputBottomSheet(
                  context, imt("修改昵称"), imt("仅限中字、字母、数字和下划线"),
                      (String nickName) async {
                        final res = await widget.controller?.updateNickName(nickName);
                        if(res?.code == 0){
                          setState(() {
                            userProfile?.nickName = nickName;
                          });
                        }
                  });
            },
            child: TIMUIKitOperationItem(
              operationName: TIM_t("昵称"),
              operationRightWidget: Text(userProfile?.nickName ?? ""),
            ),
          ),
          TIMUIKitProfileWidget.userAccountBar(
            userProfile?.userID ?? "",
          ),
          TIMUIKitProfileWidget.operationDivider(),
          GestureDetector(
              onTap: () async {
                widget.controller?.showTextInputBottomSheet(
                    context, imt("修改签名"), imt("仅限中字、字母、数字和下划线"),
                        (String selfSignature) async {
                          final res = await widget.controller?.updateSelfSignature(selfSignature);
                          if(res?.code == 0){
                            setState(() {
                              userProfile?.selfSignature = selfSignature;
                            });
                          }
                    });

              },
              child: TIMUIKitOperationItem(
                  operationName: TIM_t("个性签名"),
                  operationRightWidget:
                  Text(userProfile?.selfSignature ?? imt("这个人很懒，什么也没写")))),
          GestureDetector(
              onTap: () async {
                showGenderChoseSheet(context, theme);
              },
              child: TIMUIKitProfileWidget.genderBarWithArrow(
                  userProfile?.gender ?? 0))
        ],
      ),
    );
  }
}