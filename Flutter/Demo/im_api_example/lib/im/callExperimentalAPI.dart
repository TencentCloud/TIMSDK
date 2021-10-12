import 'package:flutter/material.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class CallExperimentalAPI extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CallExperimentalAPIState();
}

class CallExperimentalAPIState extends State<CallExperimentalAPI> {
  var resData;
  String username = '';
  List<String> users = List.empty(growable: true);
  sendC2CTextMessage() async {
    var res = await TencentImSDKPlugin.v2TIMManager.callExperimentalAPI(
      api: "initLocalStorage",
      param: username,
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
          Form(
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    labelText: "请输入用户名",
                    hintText: "调用实验性接口：初始化本地数据库（您可以在SDK中自行尝试其他接口）",
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (res) {
                    setState(() {
                      username = res;
                    });
                  },
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: sendC2CTextMessage,
                  child: Text("调用实验性接口"),
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
