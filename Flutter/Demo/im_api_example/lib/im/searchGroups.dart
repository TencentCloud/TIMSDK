import 'package:flutter/material.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_search_param.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class SearchGroups extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchGroupsState();
}

class SearchGroupsState extends State<SearchGroups> {
  Map<String, dynamic>? resData;
  String text = '';
  List<String> receiver = List.empty(growable: true);
  List<String> groupID = List.empty(growable: true);
  int priority = 0;
  bool isSearchGroupID = false;
  bool isSearchGroupName = false;
  sendTextMessage() async {
    V2TimGroupSearchParam searchParam = new V2TimGroupSearchParam(
        keywordList: [text],
        isSearchGroupID: isSearchGroupID,
        isSearchGroupName: isSearchGroupName);

    V2TimValueCallback<List<V2TimGroupInfo>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getGroupManager()
        .searchGroups(searchParam: searchParam);
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
                    labelText: "搜索关键字(最多支持五个，example只支持一个)",
                    hintText: "关键字",
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (res) {
                    setState(() {
                      text = res;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text("设置是否搜索群 ID"),
              Switch(
                value: isSearchGroupID,
                onChanged: (res) {
                  setState(() {
                    isSearchGroupID = res;
                  });
                },
              )
            ],
          ),
          Row(
            children: [
              Text("设置是否搜索群名称"),
              Switch(
                value: isSearchGroupName,
                onChanged: (res) {
                  setState(() {
                    isSearchGroupName = res;
                  });
                },
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: sendTextMessage,
                  child: Text("搜索Group"),
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
