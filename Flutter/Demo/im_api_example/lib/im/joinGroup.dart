import 'package:flutter/material.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class JoinGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => JoinGroupState();
}

class JoinGroupState extends State<JoinGroup> {
  Map<String, dynamic>? resData;
  String groupID = '';
  late String message;
  joinGroup() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager.joinGroup(
      groupID: groupID,
      message: message,
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
                    labelText: "群ID",
                    hintText: "群ID",
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (res) {
                    setState(() {
                      groupID = res;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: "进群打招呼Message",
                    hintText: "进群打招呼Message",
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (res) {
                    setState(() {
                      message = res;
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
                  onPressed: joinGroup,
                  child: Text("加入群组"),
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
