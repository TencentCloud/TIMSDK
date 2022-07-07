// ignore_for_file: unused_import

import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';

import 'package:timuikit/src/pages/login.dart';
import 'package:timuikit/src/provider/login_user_Info.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:timuikit/src/routes.dart';
import 'package:timuikit/utils/theme.dart';
import 'package:timuikit/utils/toast.dart';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

import 'about.dart';
import 'my_profile_detail.dart';
import 'pages/skin/skin_page.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfileState();
}

class _ProfileState extends State<MyProfile> {
  final CoreServicesImpl _coreServices = TIMUIKitCore.getInstance();
  final V2TIMManager sdkInstance = TIMUIKitCore.getSDKInstance();
  final TIMUIKitProfileController _timuiKitProfileController =
      TIMUIKitProfileController();
  String? userID;

  String _getAllowText(int? allowType) {
    if (allowType == 0) {
      return imt("同意任何用户加好友");
    }

    if (allowType == 1) {
      return imt("需要验证");
    }

    if (allowType == 2) {
      return imt("拒绝任何人加好友");
    }

    return imt("未知");
  }

  _handleLogout() async {
    final res = await _coreServices.logout();
    if (res.code == 0) {
      try {
        Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
        SharedPreferences prefs = await _prefs;
        prefs.remove('smsLoginUserId');
        prefs.remove('smsLoginToken');
        prefs.remove('smsLoginPhone');
        prefs.remove('channelListMain');
        prefs.remove('discussListMain');
      } catch (err) {
        Utils.log("someError");
        Utils.log(err);
      }
      Routes().directToLoginPage();

      // Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(builder: (BuildContext context) => const LoginPage()),
      //   ModalRoute.withName('/'),
      // );
    }
  }

  getLoginUser() async {
    final res = await sdkInstance.getLoginUser();
    if (res.code == 0) {
      setState(() {
        userID = res.data;
      });
    }
  }

  changeFriendVerificationMethod(int allowType) async {
    _timuiKitProfileController.changeFriendVerificationMethod(allowType);
  }

  showApplicationTypeSheet(theme) async {
    const allowAny = 0;
    const neddConfirm = 1;
    const denyAny = 2;

    showAdaptiveActionSheet(
      context: context,
      actions: <BottomSheetAction>[
        BottomSheetAction(
          title: Text(
            imt("同意任何用户加好友"),
            style: TextStyle(color: theme.primaryColor, fontSize: 18),
          ),
          onPressed: () {
            changeFriendVerificationMethod(allowAny);
            Navigator.pop(context);
          },
        ),
        BottomSheetAction(
            title: Text(
              imt("需要验证"),
              style: TextStyle(color: theme.primaryColor, fontSize: 18),
            ),
            onPressed: () {
              changeFriendVerificationMethod(neddConfirm);
              Navigator.pop(context);
            }),
        BottomSheetAction(
          title: Text(
            imt("拒绝任何人加好友"),
            style: TextStyle(color: theme.primaryColor, fontSize: 18),
          ),
          onPressed: () {
            changeFriendVerificationMethod(denyAny);
            Navigator.pop(context);
          },
        ),
      ],
      cancelAction: CancelAction(
        title: Text(
          imt("取消"),
          style: const TextStyle(fontSize: 18),
        ),
      ), // onPressed parameter is optional by default will dismiss the ActionSheet
    );
  }

  @override
  void initState() {
    super.initState();
    getLoginUser();
  }

  @override
  Widget build(BuildContext context) {
    if (userID == null) {
      return Container();
    }
    final themeType = Provider.of<DefaultThemeData>(context).currentThemeType;
    final theme = Provider.of<DefaultThemeData>(context).theme;
    final loginUserInfoModel = Provider.of<LoginUserInfo>(context);
    final V2TimUserFullInfo loginUserInfo = loginUserInfoModel.loginUserInfo;
    final int? allowType = loginUserInfo.allowType;
    final allowText = _getAllowText(allowType);

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyProfileDetail()),
            );
          },
          child: TIMUIKitProfileUserInfoCard(
            userInfo: loginUserInfo,
            showArrowRightIcon: true,
          ),
        ),
        // 好友验证方式选
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: InkWell(
            onTap: () {
              showApplicationTypeSheet(theme);
            },
            child: TIMUIKitOperationItem(
              operationName: imt("加我为好友时需要验证"),
              operationRightWidget: Text(allowText),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SkinPage(),
              ),
            );
          },
          child: TIMUIKitOperationItem(
            operationName: imt("更换皮肤"),
            operationRightWidget: Text(DefTheme.defaultThemeName[themeType]!,
                style: TextStyle(color: theme.primaryColor)),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const About(),
              ),
            );
          },
          child: TIMUIKitOperationItem(
            operationName: imt("关于腾讯云 · IM"),
            operationRightWidget: const Text(""),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        InkWell(
          onTap: _handleLogout,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
                color: Colors.white,
                border:
                    Border(bottom: BorderSide(color: hexToColor("E5E5E5")))),
            child: Text(
              imt("退出登录"),
              style: TextStyle(color: hexToColor("FF584C"), fontSize: 17),
            ),
          ),
        )
      ],
    );
  }
}
