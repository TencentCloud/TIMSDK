import 'package:flutter/material.dart';
import 'package:example/im/friendGroupSelector.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class DeleteFriendGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DeleteFriendGroupState();
}

class DeleteFriendGroupState extends State<DeleteFriendGroup> {
  Map<String, dynamic>? resData;
  List<String> fgs = List.empty(growable: true);
  deleteFriendGroup() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .deleteFriendGroup(
          groupNameList: fgs,
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
              FriendGroupSelector(
                onSelect: (data) {
                  setState(() {
                    fgs = data;
                  });
                },
                switchSelectType: false,
                value: fgs,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(fgs.length > 0 ? fgs.toString() : imt("未选择")),
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: deleteFriendGroup,
                  child: Text(imt("删除好友分组")),
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
