import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class UserSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UserSettingPage();
  }
}

class UserSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => UserSettingState();
}

class UserSettingState extends State<UserSettingPage> {
  final LocalStorage storage = new LocalStorage('im_api_example_user_info');
  String sdkappid = "";
  String secret = "";
  String userID = "";
  late TextEditingController sdkappidc;
  late TextEditingController secretc;
  late TextEditingController userIDc;
  @override
  void initState() {
    super.initState();
    String? skd = storage.getItem("sdkappid");
    String? skt = storage.getItem("secret");
    String? usd = storage.getItem("userID");
    setState(() {
      sdkappid = skd == null ? "" : skd;
      secret = skt == null ? "" : skt;
      userID = usd == null ? "" : usd;
    });
    sdkappidc = new TextEditingController(text: sdkappid);
    secretc = new TextEditingController(text: secret);
    userIDc = new TextEditingController(text: userID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("配置信息"),
      ),
      body: Container(
          child: Padding(
        padding: EdgeInsets.all(10),
        child: Form(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "sdkappid，控制台去申请",
                  hintText: "sdkappid，控制台去申请",
                  prefixIcon: Icon(Icons.person),
                ),
                keyboardType: TextInputType.number,
                controller: sdkappidc,
                onChanged: (res) {
                  setState(() {
                    sdkappid = res;
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "secret，控制台去申请",
                  hintText: "secret，控制台去申请",
                  prefixIcon: Icon(Icons.person),
                ),
                controller: secretc,
                onChanged: (res) {
                  setState(() {
                    secret = res;
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "userID，随便填",
                  hintText: "userID，随便填",
                  prefixIcon: Icon(Icons.person),
                ),
                controller: userIDc,
                onChanged: (res) {
                  setState(() {
                    userID = res;
                  });
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: sdkappid != '' && secret != '' && userID != ''
                          ? () {
                              storage.setItem("sdkappid", sdkappid);
                              storage.setItem("secret", secret);
                              storage.setItem("userID", userID);
                              // 设置成功
                              TencentImSDKPlugin.v2TIMManager
                                  .unInitSDK()
                                  .then((res) {
                                if (res.code == 0) {
                                  Navigator.pop(context);
                                }
                              });
                              // 返回
                            }
                          : null,
                      child: Text('确认设置'),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: sdkappid.length > 0 &&
                              secret.length > 0 &&
                              userID.length > 0
                          ? () {
                              storage.deleteItem('sdkappid');
                              storage.deleteItem('secret');
                              storage.deleteItem('userID');
                              sdkappidc.clear();
                              secretc.clear();
                              userIDc.clear();
                              setState(() {
                                sdkappid = '';
                                secret = '';
                                userID = '';
                              });
                            }
                          : null,
                      child: Text('清除所有配置'),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }
}
