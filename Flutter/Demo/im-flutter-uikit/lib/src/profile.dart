import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/src/contactPage.dart';
import 'package:timuikit/src/pages/login.dart';
import 'package:timuikit/utils/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

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

  Future<void> showExonerateDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(imt("免责声明")),
          content: Text(imt(
              "IM即时通信（“本产品”）是由腾讯云提供的一款测试产品，腾讯云享有本产品的著作权和所有权。本产品仅用于功能体验，不得用于任何商业用途。为配合相关部门监管要求，本产品音视频互动全程均有录音录像存档，严禁在使用中有任何色情、辱骂、暴恐、涉政等违法内容传播。")),
          actions: <Widget>[
            ElevatedButton(
              child: Text(imt("取消")),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            ElevatedButton(
              child: Text(imt("确定")),
              onPressed: () {
                //关闭对话框并返回true
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  String _getAllowText(int allowType) {
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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => const LoginPage()),
        ModalRoute.withName('/'),
      );
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

  showApplicationTypeSheet() {
    const allowAny = 0;
    const neddConfirm = 1;
    const denyAny = 2;

    showAdaptiveActionSheet(
      context: context,
      actions: <BottomSheetAction>[
        BottomSheetAction(
          title: Text(
            imt("同意任何用户加好友"),
            style: TextStyle(color: Colors.lightBlueAccent, fontSize: 18),
          ),
          onPressed: () {
            changeFriendVerificationMethod(allowAny);
            Navigator.pop(context);
          },
        ),
        BottomSheetAction(
            title: Text(
              imt("需要验证"),
              style: TextStyle(color: Colors.lightBlueAccent, fontSize: 18),
            ),
            onPressed: () {
              changeFriendVerificationMethod(neddConfirm);
              Navigator.pop(context);
            }),
        BottomSheetAction(
          title: Text(
            imt("拒绝任何人加好友"),
            style: TextStyle(color: Colors.lightBlueAccent, fontSize: 18),
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
          style: TextStyle(fontSize: 18),
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
    return TIMUIKitProfile(
      controller: _timuiKitProfileController,
      canJumpToPersonalProfile: true,
      userID: userID!,
      operationListBuilder: (context, userInfo, conversation, friendType) {
        final allowType = userInfo.userProfile?.allowType ?? 0;
        final allowText = _getAllowText(allowType);

        return Column(
          children: [
            // 好友验证方式选
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: InkWell(
                onTap: () {
                  showApplicationTypeSheet();
                },
                child: TIMUIKitOperationItem(
                  operationName: imt("加我为好友时需要验证"),
                  operationRightWidget: Text(allowText),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                launch('https://cloud.tencent.com/product/im');
              },
              child: TIMUIKitOperationItem(
                operationName: imt("关于腾讯云·通信"),
                operationRightWidget: Text(""),
              ),
            ),
            Container(
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          Color(int.parse('ededed', radix: 16)).withAlpha(255),
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    launch(
                        'https://web.sdk.qcloud.com/document/Tencent-IM-Privacy-Protection-Guidelines.html');
                  },
                  child: TIMUIKitOperationItem(
                    operationName: imt("隐私条例"),
                    operationRightWidget: Text(""),
                  ),
                )),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(int.parse('ededed', radix: 16)).withAlpha(255),
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              child: InkWell(
                onTap: () {
                  showExonerateDialog();
                },
                child: TIMUIKitOperationItem(
                  operationName: imt("免责声明"),
                  operationRightWidget: Text(""),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactPage(),
                  ),
                );
              },
              child: TIMUIKitOperationItem(
                operationName: imt("联系我们"),
                operationRightWidget: Text(""),
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        );
      },
      bottomOperationBuilder: (context, friendInfo, conversation, friendType) {
        return InkWell(
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
        );
      },
    );
  }
}
