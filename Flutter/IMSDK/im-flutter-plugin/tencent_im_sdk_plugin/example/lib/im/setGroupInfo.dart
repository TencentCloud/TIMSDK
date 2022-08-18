import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:example/im/groupSelector.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/enum/group_add_opt_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';
import 'package:example/utils/customerField/CustomerField.dart';

class SetGroupInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SetGroupInfoState();
}

class SetGroupInfoState extends State<SetGroupInfo> {
  Map<String, dynamic>? resData;
  Map<String, String> customInfo = Map();

  String? groupName = '';
  List<String> group = List.empty(growable: true);
  String groupType = "Work";
  String? notification;
  String? introduction;
  String? faceUrl;
  bool isSupportTopic = false;
  bool isAllMuted = false;
  int? addOpt = GroupAddOptType.V2TIM_GROUP_ADD_AUTH;
  setGroupInfo() async {
    V2TimCallback res =
        await TencentImSDKPlugin.v2TIMManager.getGroupManager().setGroupInfo(
              info: V2TimGroupInfo.fromJson(
                {
                  "groupID": group.first,
                  "groupName": groupName,
                  "groupType": groupType,
                  "notification": notification,
                  "introduction": introduction,
                  "faceUrl": faceUrl,
                  "isAllMuted": isAllMuted,
                  "addOpt": addOpt,
                  "customInfo": customInfo,
                  "isSupportTopic":isSupportTopic,
                },
              ),
            );
    this.setState(() {
      resData = res.toJson();
    });
  }

  onSetField(Map<String, String> res) {
    setState(() {
      customInfo = res;
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
                      Row(
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
                              child: Text(
                                  group.length > 0 ? group.toString() : imt("未选择")),
                            ),
                          )
                        ],
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
                      TextField(
                        decoration: InputDecoration(
                          labelText: imt("群通告"),
                          hintText: imt("群通告"),
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
                          labelText: imt("群简介"),
                          hintText: imt("群简介"),
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
                                    title: Text(imt("群头像")),
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
                                child: Text(imt("选择群头像")),
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
                          Text(imt("是否全员禁言")),
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
                          Text(imt("是否支持话题")),
                          Switch(
                            value: isSupportTopic ,
                            onChanged: (res) {
                              setState(() {
                                isSupportTopic  = res;
                              });
                            },
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
                                      BottomSheetAction(
                                        title: Text(imt("Community 社群")),
                                        onPressed: () {
                                          setState(() {
                                            groupType = 'Community';
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
                                    title: Text(imt("选择加群类型")),
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
                                child: Text(imt("选择加群类型")),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 12),
                              child: Text("已选：$addOpt"),
                            )
                          ],
                        ),
                      ),
                      CustomerField(
                        onSetField: onSetField,
                        maxSetCount: 10,
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
                  onPressed: setGroupInfo,
                  child: Text(imt("设置群信息")),
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
