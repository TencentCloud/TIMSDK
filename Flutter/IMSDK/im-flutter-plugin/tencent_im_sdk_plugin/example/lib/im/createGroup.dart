import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_change_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_topic_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_topic_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class CreateGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CreateGroupState();
}

class CreateGroupState extends State<CreateGroup> {
  Map<String, dynamic>? resData;

  String groupName = '';
  String groupID = '';
  String groupType = "Work";
  // 3.6.0 后不建议使用简单方法创建群
  createGroup() async {
    // V2TimValueCallback<String> res =
    //     await TencentImSDKPlugin.v2TIMManager.createGroup(
    //   groupType: groupType,
    //   groupName: groupName,
    //   groupID: groupID,
    // );
    // @TGS#_@TGS#cKGKWHIM62CT
    // V2TimValueCallback<List<V2TimGroupInfo>> res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getJoinedCommunityList();
    // V2TimValueCallback<String> res1 = await TencentImSDKPlugin.v2TIMManager.getGroupManager().createTopicInCommunity(groupID: "@TGS#_@TGS#cKGKWHIM62CT", topicInfo: V2TimTopicInfo.fromJson({
    //   "topicName":"测试topic4"
    // }));
  //  V2TimCallback res =  await TencentImSDKPlugin.v2TIMManager.getGroupManager().setTopicInfo(topicInfo: V2TimTopicInfo.fromJson({
  //     "topicName":"测试topic_modify",
  //     "topicID": "@TOPIC#_@TOPIC#cPGKWHIM62CO"
  //   }));
    V2TimValueCallback<List<V2TimMessage>> messagelist = await TencentImSDKPlugin.v2TIMManager.getMessageManager().findMessages(messageIDList: ["144115263066194686-1653386915-896225847"]);
    V2TimValueCallback<String> user = await TencentImSDKPlugin.v2TIMManager.getLoginUser();
    V2TimMessage msg = messagelist.data!.first;

    msg.textElem!.text = user.data;
    V2TimValueCallback<V2TimMessageChangeInfo> res = await TencentImSDKPlugin.v2TIMManager.getMessageManager().modifyMessage(message: msg);
    // V2TimValueCallback<List<V2TimTopicInfoResult>> res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getTopicInfoList(groupID: "@TGS#_@TGS#cKGKWHIM62CT", topicIDList: []);
    this.setState(() {
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
                child: Form(
                  child: Column(
                    children: <Widget>[
                      TextField(
                        decoration: InputDecoration(
                          labelText: imt("群ID"),
                          hintText: imt("选填（如填，则自定义群ID）"),
                          prefixIcon: Icon(Icons.person),
                        ),
                        onChanged: (res) {
                          setState(() {
                            groupID = res;
                          });
                        },
                      ),
                      TextField(
                        decoration: InputDecoration(
                          labelText: imt("群名称"),
                          hintText: imt("群名称"),
                          prefixIcon: Icon(Icons.person),
                        ),
                        onChanged: (res) {
                          setState(() {
                            groupName = res;
                          });
                        },
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Icon(
                                Icons.person,
                                color: Colors.black45,
                              ),
                              margin: EdgeInsets.only(left: 12),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 12),
                              child: ElevatedButton(
                                onPressed: () {
                                  showAdaptiveActionSheet(
                                    context: context,
                                    title: Text(imt("选择群类型")),
                                    actions: <BottomSheetAction>[
                                      BottomSheetAction(
                                        title: Text(imt("Work 工作群")),
                                        onPressed: () {
                                          setState(() {
                                            groupType = 'Work';
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      BottomSheetAction(
                                        title: Text(imt("Public 公开群")),
                                        onPressed: () {
                                          setState(() {
                                            groupType = 'Public';
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      BottomSheetAction(
                                        title: Text(imt("Meeting 会议群")),
                                        onPressed: () {
                                          setState(() {
                                            groupType = 'Meeting';
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      BottomSheetAction(
                                        title: Text(imt("AVChatRoom 直播群")),
                                        onPressed: () {
                                          setState(() {
                                            groupType = 'AVChatRoom';
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                    cancelAction: CancelAction(
                                      title: const Text('Cancel'),
                                    ), // onPressed parameter is optional by default will dismiss the ActionSheet
                                  );
                                },
                                child: Text(imt("选择群类型")),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 12),
                              child: Text("已选：$groupType"),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          new Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: createGroup,
                  child: Text(imt("创建群")),
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
// DropdownButton<String>(
//                         hint: Text(imt(imt("群类型"))),
//                         icon: Icon(Icons.person),
//                         items: [
//                           DropdownMenuItem<String>(
//                             child: Text(imt(imt("群类型：Work"))),
//                             value: "Work",
//                           ),
//                           DropdownMenuItem<String>(
//                             child: Text(imt(imt("群类型：Public"))),
//                             value: "Public",
//                           ),
//                           DropdownMenuItem<String>(
//                             child: Text(imt(imt("群类型：Meeting"))),
//                             value: "Meeting",
//                           ),
//                           DropdownMenuItem<String>(
//                             child: Text(imt(imt("群类型r：AVChatRoom"))),
//                             value: "AVChatRoom",
//                           )
//                         ],
//                         value: "Work",
//                         isExpanded: false,
//                         onChanged: (res) {},
//                       ),
