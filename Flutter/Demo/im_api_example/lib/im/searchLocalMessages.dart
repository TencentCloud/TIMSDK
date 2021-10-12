import 'package:flutter/material.dart';
import 'package:im_api_example/im/conversationSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_search_param.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class SearchLocalMessages extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchLocalMessagesState();
}

class SearchLocalMessagesState extends State<SearchLocalMessages> {
  Map<String, dynamic>? resData;
  String keyword = '';
  List<String> conversaions = List.empty(growable: true);
  searchLocaltMessage() async {
    if (keyword == '') return;
    V2TimMessageSearchParam searchParam = V2TimMessageSearchParam(
      keywordList: [keyword],
      type: 1, // 对应 keywordListMatchType sdk层处理  代表 或 与关系
      pageSize: 50, // size 写死
      pageIndex: 1, // index写死
      conversationID: conversaions.first, // 不传代表指定所有会话
    );
    var res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .searchLocalMessages(searchParam: searchParam);
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
                    labelText: "关键字(必填)",
                    hintText: "关键字（接口支持5个，example支持一个）",
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (res) {
                    setState(() {
                      keyword = res;
                    });
                  },
                ),
              ),
            ],
          ),
          new Row(
            children: [
              ConversationSelector(
                onSelect: (data) {
                  setState(() {
                    conversaions = data;
                  });
                },
                switchSelectType: true,
                value: conversaions,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(conversaions.length > 0
                      ? conversaions.toString()
                      : "未选择"),
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
              Expanded(
                child: ElevatedButton(
                  onPressed: searchLocaltMessage,
                  child: Text("查询本地消息"),
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
