import 'package:flutter/material.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';

import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class RenameFriendGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RenameFriendGroupState();
}

class RenameFriendGroupState extends State<RenameFriendGroup> {
  Map<String, dynamic>? resData;
  String oldGroupName = '';
  String newGroupName = '';
  List<String> users = List.empty(growable: true);
  renameFriendGroup() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .renameFriendGroup(
          oldName: oldGroupName,
          newName: newGroupName,
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
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "旧分组名",
                    hintText: "旧分组名",
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (res) {
                    setState(() {
                      oldGroupName = res;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "新分组名",
                    hintText: "新分组名",
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (res) {
                    setState(() {
                      newGroupName = res;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: renameFriendGroup,
                  child: Text("重命名好友分组"),
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
