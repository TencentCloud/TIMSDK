import 'package:flutter/material.dart';
import 'package:im_api_example/im/groupSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class ClearGroupHistoryMessage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ClearGroupHistoryMessageState();
}

class ClearGroupHistoryMessageState extends State<ClearGroupHistoryMessage> {
  List<String> groupID = List.empty(growable: true);
  Map<String, dynamic>? resData;
  getGroupsInfo() async {
    var res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .clearGroupHistoryMessage(
          groupID: groupID.length > 0 ? groupID.first : "",
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
              GroupSelector(
                onSelect: (data) {
                  setState(() {
                    groupID = data;
                  });
                },
                switchSelectType: true,
                value: groupID,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(groupID.length > 0 ? groupID.toString() : "未选择"),
                ),
              )
            ],
          ),
          new Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: getGroupsInfo,
                  child: Text("获取群组信息"),
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
