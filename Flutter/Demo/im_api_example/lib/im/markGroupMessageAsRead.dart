import 'package:flutter/material.dart';
import 'package:im_api_example/im/groupSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class MarkGroupMessageAsRead extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MarkGroupMessageAsReadState();
}

class MarkGroupMessageAsReadState extends State<MarkGroupMessageAsRead> {
  Map<String, dynamic>? resData;
  List<String> group = List.empty(growable: true);
  markGroupMessageAsRead() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .markGroupMessageAsRead(
          groupID: group.first,
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
                new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GroupSelector(
                      onSelect: (data) {
                        setState(() {
                          group = data;
                        });
                      },
                      switchSelectType: true,
                      value: group,
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child:
                            Text(group.length > 0 ? group.toString() : "未选择"),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: markGroupMessageAsRead,
                  child: Text("标记group会话已读"),
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
