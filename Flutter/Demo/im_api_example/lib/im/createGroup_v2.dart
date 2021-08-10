import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:im_api_example/im/friendSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/enum/group_add_opt_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class CreateGroupV2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CreateGroupV2State();
}

class CreateGroupV2State extends State<CreateGroupV2> {
  Map<String, dynamic>? resData;

  String groupName = '';
  String? groupID;
  String groupType = "Work";
  String? notification;
  String? introduction;
  String? faceUrl;
  bool isAllMuted = false;
  int? addOpt = GroupAddOptType.V2TIM_GROUP_ADD_AUTH;
  List<String> memberList = List.empty(growable: true);
  createGroupv2() async {
    V2TimValueCallback<String> res =
        await TencentImSDKPlugin.v2TIMManager.getGroupManager().createGroup(
              groupType: groupType,
              groupName: groupName,
              groupID: groupID,
              notification: notification,
              introduction: introduction,
              isAllMuted: isAllMuted,
              faceUrl: faceUrl,
              addOpt: addOpt,
            );
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
                          labelText: "群ID",
                          hintText: "选填（如填，则自定义群ID）",
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
                          labelText: "群名称",
                          hintText: "群名称",
                          prefixIcon: Icon(Icons.person),
                        ),
                        onChanged: (res) {
                          setState(() {
                            groupName = res;
                          });
                        },
                      ),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "群通告",
                          hintText: "群通告",
                          prefixIcon: Icon(Icons.person),
                        ),
                        onChanged: (res) {
                          setState(() {
                            notification = res;
                          });
                        },
                      ),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "群简介",
                          hintText: "群简介",
                          prefixIcon: Icon(Icons.person),
                        ),
                        onChanged: (res) {
                          setState(() {
                            introduction = res;
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
                                    title: const Text('群头像'),
                                    actions: <BottomSheetAction>[
                                      BottomSheetAction(
                                        title: Image.network(
                                          "https://imgcache.qq.com/operation/dianshi/other/y2QNRn.efeeba9865fac2e6dbbeb8fafcc62a3d3cc1e0a6.png",
                                          width: 40,
                                          height: 40,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            faceUrl =
                                                'https://imgcache.qq.com/operation/dianshi/other/y2QNRn.efeeba9865fac2e6dbbeb8fafcc62a3d3cc1e0a6.png';
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      BottomSheetAction(
                                        title: Image.network(
                                          "https://imgcache.qq.com/operation/dianshi/other/vmuM7b.38bc8a9b478927da82ab0209773b5c8154d81469.jpeg",
                                          width: 40,
                                          height: 40,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            faceUrl =
                                                "https://imgcache.qq.com/operation/dianshi/other/vmuM7b.38bc8a9b478927da82ab0209773b5c8154d81469.jpeg";
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      BottomSheetAction(
                                        title: Image.network(
                                          "https://imgcache.qq.com/operation/dianshi/other/6vQ3U3.216b02313fa2374d2e44283490df64975712be5a.jpeg",
                                          width: 40,
                                          height: 40,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            faceUrl =
                                                "https://imgcache.qq.com/operation/dianshi/other/6vQ3U3.216b02313fa2374d2e44283490df64975712be5a.jpeg";
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      BottomSheetAction(
                                        title: Image.network(
                                          "https://imgcache.qq.com/operation/dianshi/other/jYNR3e.909696a6a93a853a056bf71da21f8938a906d6f3.png",
                                          width: 40,
                                          height: 40,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            faceUrl =
                                                "https://imgcache.qq.com/operation/dianshi/other/jYNR3e.909696a6a93a853a056bf71da21f8938a906d6f3.png";
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
                                child: Text("选择群头像"),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 12),
                              child: faceUrl != null
                                  ? Image.network(
                                      faceUrl!,
                                      width: 40,
                                      height: 40,
                                    )
                                  : Container(),
                            )
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text("是否全员禁言"),
                          Switch(
                            value: isAllMuted,
                            onChanged: (res) {
                              setState(() {
                                isAllMuted = res;
                              });
                            },
                          )
                        ],
                      ),
                      Row(
                        children: [
                          FriendSelector(
                            onSelect: (data) {
                              setState(() {
                                memberList = data;
                              });
                            },
                            switchSelectType: false,
                            value: memberList,
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Text(memberList.length > 0
                                  ? memberList.toString()
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
                                    title: const Text('选择群类型'),
                                    actions: <BottomSheetAction>[
                                      BottomSheetAction(
                                        title: const Text('Work 工作群'),
                                        onPressed: () {
                                          setState(() {
                                            groupType = 'Work';
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      BottomSheetAction(
                                        title: const Text('Public 公开群'),
                                        onPressed: () {
                                          setState(() {
                                            groupType = 'Public';
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      BottomSheetAction(
                                        title: const Text('Meeting 会议群'),
                                        onPressed: () {
                                          setState(() {
                                            groupType = 'Meeting';
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      BottomSheetAction(
                                        title: const Text('AVChatRoom 直播群'),
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
                                child: Text("选择群类型"),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 12),
                              child: Text('已选：$groupType'),
                            )
                          ],
                        ),
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
                                    title: const Text('选择加群类型'),
                                    actions: <BottomSheetAction>[
                                      BottomSheetAction(
                                        title:
                                            const Text('V2TIM_GROUP_ADD_ANY'),
                                        onPressed: () {
                                          setState(() {
                                            addOpt = GroupAddOptType
                                                .V2TIM_GROUP_ADD_ANY;
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      BottomSheetAction(
                                        title:
                                            const Text('V2TIM_GROUP_ADD_AUTH'),
                                        onPressed: () {
                                          setState(() {
                                            addOpt = GroupAddOptType
                                                .V2TIM_GROUP_ADD_AUTH;
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                      BottomSheetAction(
                                        title: const Text(
                                            'V2TIM_GROUP_ADD_FORBID'),
                                        onPressed: () {
                                          setState(() {
                                            addOpt = GroupAddOptType
                                                .V2TIM_GROUP_ADD_FORBID;
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
                                child: Text("选择加群类型"),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 12),
                              child: Text('已选：$addOpt'),
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
                  onPressed: createGroupv2,
                  child: Text("高级创建群"),
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
//                         hint: Text('群类型'),
//                         icon: Icon(Icons.person),
//                         items: [
//                           DropdownMenuItem<String>(
//                             child: Text('群类型：Work'),
//                             value: "Work",
//                           ),
//                           DropdownMenuItem<String>(
//                             child: Text('群类型：Public'),
//                             value: "Public",
//                           ),
//                           DropdownMenuItem<String>(
//                             child: Text('群类型：Meeting'),
//                             value: "Meeting",
//                           ),
//                           DropdownMenuItem<String>(
//                             child: Text('群类型r：AVChatRoom'),
//                             value: "AVChatRoom",
//                           )
//                         ],
//                         value: "Work",
//                         isExpanded: false,
//                         onChanged: (res) {},
//                       ),
