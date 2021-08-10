import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class Logout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LogoutState();
}

class LogoutState extends State<Logout> {
  logout() async {
    TencentImSDKPlugin.v2TIMManager.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          new Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: logout,
                  child: Text("登出"),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
