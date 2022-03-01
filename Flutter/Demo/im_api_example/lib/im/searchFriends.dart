import 'package:flutter/material.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_search_param.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:im_api_example/i18n/i18n_utils.dart';

class SearchFriends extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchFriendsState();
}

class SearchFriendsState extends State<SearchFriends> {
  Map<String, dynamic>? resData;
  String text = '';
  List<String> receiver = List.empty(growable: true);
  List<String> groupID = List.empty(growable: true);
  int priority = 0;
  bool isSearchUserID = false;
  bool isSearchNickName = false;
  bool isSearchRemark = false;

  sendTextMessage() async {
    V2TimFriendSearchParam searchParam = new V2TimFriendSearchParam(
        keywordList: [text],
        isSearchUserID: isSearchUserID,
        isSearchNickName: isSearchNickName,
        isSearchRemark: isSearchRemark);
    var res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .searchFriends(searchParam: searchParam);
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
                    labelText: imt("搜索关键字列表，最多支持5个"),
                    hintText: imt("关键字(example只有设置了一个关键字)"),
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
          Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black45,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Text(imt("设置是否搜索userID")),
              Switch(
                value: isSearchUserID,
                onChanged: (res) {
                  setState(() {
                    isSearchUserID = res;
                  });
                },
              )
            ],
          ),
          Row(
            children: [
              Text(imt("是否设置搜索昵称")),
              Switch(
                value: isSearchNickName,
                onChanged: (res) {
                  setState(() {
                    isSearchNickName = res;
                  });
                },
              )
            ],
          ),
          Row(
            children: [
              Text(imt("设置是否搜索备注")),
              Switch(
                value: isSearchRemark,
                onChanged: (res) {
                  setState(() {
                    isSearchRemark = res;
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
                  child: Text(imt("搜索好友")),
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
