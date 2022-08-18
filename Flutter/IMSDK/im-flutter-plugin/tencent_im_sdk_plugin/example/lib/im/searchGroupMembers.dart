import 'package:flutter/material.dart';
import 'package:example/im/groupSelector.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_search_param.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class SearchGroupMembers extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchGroupMembersState();
}

class SearchGroupMembersState extends State<SearchGroupMembers> {
  Map<String, dynamic>? resData;
  String text = '';
  List<String> receiver = List.empty(growable: true);
  List<String> groupID = List.empty(growable: true);
  int priority = 0;
  bool isSearchMemberUserID = false;
  bool isSearchMemberNickName = false;
  bool isSearchMemberRemark = false;
  bool isSearchMemberNameCard = false;
V2TimGroupMemberSearchParam? searchGroupMembers;
  @override
  initState(){
    searchGroupMembers =
         V2TimGroupMemberSearchParam(
      groupIDList: groupID,
      keywordList: [text],
    );
  }
  sendTextMessage() async {
    searchGroupMembers!.groupIDList = groupID;
    searchGroupMembers!.keywordList = [text];
    searchGroupMembers!.isSearchMemberNickName = isSearchMemberNickName;
    searchGroupMembers!.isSearchMemberRemark = isSearchMemberRemark;
    searchGroupMembers!.isSearchMemberNameCard = isSearchMemberNameCard;
    print(searchGroupMembers!.toJson());
    var res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .searchGroupMembers(param: searchGroupMembers!);
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
                    hintText: imt("关键字"),
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
                  child: Text(groupID.length > 0 ? groupID.toString() : imt("未选择")),
                ),
              )
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
              Text(imt("设置是否搜索群成员 userID")),
              Switch(
                value: isSearchMemberUserID,
                onChanged: (res) {
                  setState(() {
                    isSearchMemberUserID = res;
                  });
                },
              )
            ],
          ),
          Row(
            children: [
              Text(imt("设置是否搜索群成员昵称")),
              Switch(
                value: isSearchMemberNickName,
                onChanged: (res) {
                  setState(() {
                    isSearchMemberNickName = res;
                  });
                },
              )
            ],
          ),
          Row(
            children: [
              Text(imt("设置是否搜索群成员名片")),
              Switch(
                value: isSearchMemberNameCard,
                onChanged: (res) {
                  setState(() {
                    isSearchMemberNameCard = res;
                  });
                },
              )
            ],
          ),
          Row(
            children: [
              Text(imt("设置是否搜索群成员备注")),
              Switch(
                value: isSearchMemberRemark,
                onChanged: (res) {
                  setState(() {
                    isSearchMemberRemark = res;
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
                  child: Text(imt("搜索群成员")),
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
