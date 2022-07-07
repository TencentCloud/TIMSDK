// ignore_for_file: use_key_in_widget_constructors, unused_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/src/pages/login.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:provider/provider.dart';
import 'package:timuikit/src/routes.dart';
import 'package:timuikit/utils/request.dart';
import 'package:timuikit/utils/toast.dart';
import 'config.dart';

import 'package:dio/dio.dart';

class CancelAccount extends StatelessWidget {
  final TUISelfInfoViewModel _selfInfoViewModel =
      serviceLocator<TUISelfInfoViewModel>();
  final CoreServicesImpl _coreServices = TIMUIKitCore.getInstance();

  _handleLogout(BuildContext context) async {
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

  CupertinoActionSheet mapAppSheet(BuildContext context) {
    return CupertinoActionSheet(
      title: Text(imt("确认注销账户")),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () async {
            Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
            SharedPreferences prefs = await _prefs;
            String token = prefs.getString("smsLoginToken") ?? "";
            String userID = prefs.getString("smsLoginUserID") ?? "";
            String appID = prefs.getString("sdkAppId") ?? "";

            Response<Map<String, dynamic>> data = await appRequest(
                path:
                    "/base/v1/auth_users/user_delete?apaasUserId=$userID&userId=$userID&token=$token&apaasAppId=$appID",
                method: "get",
                data: <String, dynamic>{
                  "apaasUserId": userID,
                  "userId": userID,
                  "token": token,
                  "apaasAppId": appID
                });

            Map<String, dynamic> res = data.data!;
            int errorCode = res['errorCode'];
            String? codeStr = res['codeStr'];

            if (errorCode == 0) {
              Utils.toast((imt("账户注销成功！")));
              _handleLogout(context);
            } else {
              Utils.log(codeStr);
              Utils.toast(codeStr ?? "");
            }
          },
          child: Text(
            imt("注销"),
            style: TextStyle(
              fontSize: 17.0,
              color: hexToColor("FF584C"),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    final option1 = _selfInfoViewModel.loginInfo?.userID;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        shadowColor: theme.weakDividerColor,
        elevation: 1,
        title: Text(
          imt("注销账户"),
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
      body: Container(
        decoration: BoxDecoration(
          color: hexToColor("E6E9EB"),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundImage: NetworkImage(
                          _selfInfoViewModel.loginInfo?.faceUrl ?? ""),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Icon(
                      Icons.do_not_disturb_on,
                      color: hexToColor('FA5151'),
                      size: 34,
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 80),
                padding: const EdgeInsets.only(right: 40, left: 40),
                child: Text(
                  imt_para("注销后，您将无法使用当前账号，相关数据也将删除且无法找回。当前账号ID: {{option1}}",
                          "注销后，您将无法使用当前账号，相关数据也将删除且无法找回。当前账号ID: $option1")(
                      option1: option1),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: hexToColor("444444"),
                    fontSize: 14,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 40, left: 40),
                child: MaterialButton(
                  elevation: 0,
                  highlightElevation: 0,
                  minWidth: double.infinity,
                  color: Colors.white,
                  textColor: hexToColor("FA5151"),
                  height: 46,
                  child: Text(
                    imt("注销账号"),
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  onPressed: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) =>
                            mapAppSheet(context)).then((value) => null);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
