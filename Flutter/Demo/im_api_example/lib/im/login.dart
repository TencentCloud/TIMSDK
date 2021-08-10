import 'package:flutter/material.dart';
import 'package:im_api_example/utils/GenerateTestUserSig.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:localstorage/localstorage.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {
  final LocalStorage storage = new LocalStorage('im_api_example_user_info');
  Map<String, dynamic>? resData;
  login() async {
    String userID = storage.getItem("userID");
    // 正式环境请在服务端计算userSIg
    String userSig = new GenerateTestUserSig(
      sdkappid: int.parse(storage.getItem("sdkappid")),
      key: storage.getItem("secret"),
    ).genSig(
      identifier: userID,
      expire: 7 * 24 * 60 * 1000, // userSIg有效期
    );
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager.login(
      userID: userID,
      userSig: userSig,
    );
    setState(() {
      resData = res.toJson();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: login,
                  child: Text("登录"),
                ),
              )
            ],
          ),
          SDKResponse(resData),
        ],
      ),
    );
  }
}
