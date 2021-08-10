import 'package:flutter/material.dart';
import 'package:im_api_example/im/groupSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class DismissGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DismissGroupState();
}

class DismissGroupState extends State<DismissGroup> {
  Map<String, dynamic>? resData;
  late List<String> groups = List.empty(growable: true);
  dismissGroup() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager.dismissGroup(
      groupID: groups.first,
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
                    groups = data;
                  });
                },
                switchSelectType: true,
                value: groups,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(groups.length > 0 ? groups.toString() : "未选择"),
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: dismissGroup,
                  child: Text("解散群组"),
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
