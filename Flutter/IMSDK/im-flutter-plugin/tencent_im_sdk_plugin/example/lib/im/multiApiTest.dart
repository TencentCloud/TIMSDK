import 'package:flutter/material.dart';
import 'package:example/im/conversationSelector.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/enum/conversation_type.dart';
import 'package:tencent_im_sdk_plugin/enum/v2_tim_conversation_marktype.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:example/i18n/i18n_utils.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversationList_filter.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_topic_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_topic_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_topic_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class MultiApiTest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MultiApiTestState();
}

class MultiApiTestState extends State<MultiApiTest> {
  String communityID = "";
  String t1 = "";
  String t2 = "";
  createCommunity() async {
    V2TimValueCallback<String> res  = await TencentImSDKPlugin.v2TIMManager.getGroupManager().createGroup(groupType: "Community", groupName: "社区测试",isSupportTopic: true,);
    setState(() {
      print("当前社区ID ${res.data!}");
      communityID = res.data!;
    });
  }
  createTopic() async{
    V2TimValueCallback<String> res1 = await TencentImSDKPlugin.v2TIMManager.getGroupManager().createTopicInCommunity(groupID: communityID, topicInfo: V2TimTopicInfo(
      topicName: "一个话题"
    ));
    // V2TimValueCallback<String> res2 =  await TencentImSDKPlugin.v2TIMManager.getGroupManager().createTopicInCommunity(groupID: communityID, topicInfo: V2TimTopicInfo(
    //   topicName: "二个话题"
    // ));
    setState(() {
      t1 = res1.data!;
      // t2 = res2.data!;
    });
    print("当前话题ids 1:${res1.data!}, ");
  }
  setTopicInfo() async{
    V2TimCallback res1 = await TencentImSDKPlugin.v2TIMManager.getGroupManager().setTopicInfo(groupID: communityID, topicInfo: V2TimTopicInfo(
      topicID: t1,
      topicName: "一个话题 新"
    ));
    // V2TimCallback res2 = await TencentImSDKPlugin.v2TIMManager.getGroupManager().setTopicInfo(groupID: communityID, topicInfo: V2TimTopicInfo(
    //   topicID: t2,
    //   topicName: "二个话题 新"
    // ));
    print("当前修改回调 1:${res1.toJson()},");
  }
  getTopicList() async {
    V2TimValueCallback<List<V2TimTopicInfoResult>> res1 = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getTopicInfoList(groupID: communityID, topicIDList: []);
    V2TimValueCallback<List<V2TimTopicInfoResult>> res2 = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getTopicInfoList(groupID: communityID, topicIDList: [t1]);
    print("当前列表信息 ${res1.toJson()}");
     print("当前列表信息 ${res2.toJson()}");
  }
  deletTopic() async {
    V2TimValueCallback<List<V2TimTopicOperationResult>> res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().deleteTopicFromCommunity(groupID: communityID, topicIDList: [t1]);
    print("当前删除信息 ${res.toJson()}");
  }
  setConvCustomData() async{
    V2TimValueCallback<List<V2TimConversationOperationResult>> res1 = await TencentImSDKPlugin.v2TIMManager.getConversationManager().setConversationCustomData(customData: "customData12312", conversationIDList: ["c2c_121405","c2c_10045363"]);
    print("当前列表信息 ${res1.toJson()}");
  }
  markConv() async {
V2TimValueCallback<List<V2TimConversationOperationResult>> res1 = await TencentImSDKPlugin.v2TIMManager.getConversationManager().markConversation(conversationIDList: ["c2c_121405","c2c_10045363"],markType: V2TimConversationMarkType.V2TIM_CONVERSATION_MARK_TYPE_FOLD,enableMark: true);
    print("当前列表信息 ${res1.toJson()}");
  }
  getConVList() async{
    V2TimValueCallback<V2TimConversationResult> res1 = await TencentImSDKPlugin.v2TIMManager.getConversationManager().getConversationListByFilter(filter: V2TimConversationListFilter(
      conversationType: ConversationType.V2TIM_C2C,
      markType: V2TimConversationMarkType.V2TIM_CONVERSATION_MARK_TYPE_FOLD,
      count: 10,
      nextSeq: 0,
    ));
    print("当前列表信息 ${res1.toJson()}");
  }
  createConvGroup() async{
   V2TimValueCallback<List<V2TimConversationOperationResult>> res1 = await TencentImSDKPlugin.v2TIMManager.getConversationManager().createConversationGroup(groupName: "个分组", conversationIDList: ["c2c_121405","c2c_10045363"]);
    V2TimValueCallback<List<V2TimConversationOperationResult>> res2 = await TencentImSDKPlugin.v2TIMManager.getConversationManager().createConversationGroup(groupName: "个分组", conversationIDList: ["c2c_121405","c2c_10045363"]);
  print("当前列表信息 ${res1.toJson()}");
  print("当前列表信息 ${res2.toJson()}");
  }
  renameConvGroup() async {
V2TimCallback res1 = await TencentImSDKPlugin.v2TIMManager.getConversationManager().renameConversationGroup(oldName: "个分组",newName: "个分组 新");
V2TimCallback res2 = await TencentImSDKPlugin.v2TIMManager.getConversationManager().renameConversationGroup(oldName: "dd个分组",newName: "dd个分组 新");
  print("当前列表信息 ${res1.toJson()}");
  print("当前列表信息 ${res2.toJson()}");
  }
  getConvGroupList() async{
    V2TimValueCallback<List<String>> res1 = await TencentImSDKPlugin.v2TIMManager.getConversationManager().getConversationGroupList();
    print("当前列表信息 ${res1.toJson()}");
  }
  addUserToConvGroup() async {
V2TimValueCallback<List<V2TimConversationOperationResult>> res1 = await TencentImSDKPlugin.v2TIMManager.getConversationManager().addConversationsToGroup(groupName: "个分组 新", conversationIDList: ["c2c_10040818"]);
 print("当前列表信息 ${res1.toJson()}");
  }
   removeUserFromConvGroup()async{
V2TimValueCallback<List<V2TimConversationOperationResult>> res1 = await TencentImSDKPlugin.v2TIMManager.getConversationManager().deleteConversationsFromGroup(groupName: "个分组 新", conversationIDList: ["c2c_10040818"]);
 print("当前列表信息 ${res1.toJson()}");
  }
  deleteConvGroup()async{
V2TimCallback res1 = await TencentImSDKPlugin.v2TIMManager.getConversationManager().deleteConversationGroup(groupName: "个分组 新");
 print("当前列表信息 ${res1.toJson()}");
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(onPressed: createCommunity, child: const Text("创建社群")),
        ElevatedButton(onPressed: createTopic, child: const Text("创建话题")),
        ElevatedButton(onPressed: setTopicInfo, child: const Text("设置话题信息")),
        ElevatedButton(onPressed: getTopicList, child: const Text("查看社群下话题列表")),
        ElevatedButton(onPressed: deletTopic, child: const Text("删除话题")),
        ElevatedButton(onPressed: setConvCustomData, child: const Text("设置会话自定义信息")),
        ElevatedButton(onPressed: markConv, child: const Text("标记话题")),
        ElevatedButton(onPressed: getConVList, child: const Text("高级获取会话列表")),
        ElevatedButton(onPressed: createConvGroup, child: const Text("创建会话分组")),
        ElevatedButton(onPressed: renameConvGroup, child: const Text("修改会话分组名字")),
        ElevatedButton(onPressed: getConvGroupList, child: const Text("获取会话分组列表")),
        ElevatedButton(onPressed: addUserToConvGroup, child: const Text("添加人到会话分组")),
        ElevatedButton(onPressed: removeUserFromConvGroup, child: const Text("从会话分组中删除人")),
        ElevatedButton(onPressed: deleteConvGroup, child: const Text("删除会话分组")),
      ],
    );
  }
}
