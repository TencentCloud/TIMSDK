import 'package:flutter/material.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class GetJoinedGroupList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GetJoinedGroupListState();
}

class GetJoinedGroupListState extends State<GetJoinedGroupList> {
  Map<String, dynamic>? resData;
  getJoinedGroupList() async {
    V2TimValueCallback<List<V2TimGroupInfo>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getGroupManager()
        .getJoinedGroupList();
    setState(() {
      resData = res.toJson();
    });
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
                  onPressed: getJoinedGroupList,
                  child: Text("获取加群列表"),
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
