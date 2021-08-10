import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/group_application_handle_result.dart';
import 'package:tencent_im_sdk_plugin/enum/group_application_handle_status.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin_example/common/avatar.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:tencent_im_sdk_plugin_example/provider/friendApplication.dart';
import 'package:tencent_im_sdk_plugin_example/provider/groupApplication.dart';
import 'package:tencent_im_sdk_plugin_example/utils/toast.dart';

class NewFriendOrGroupNotice extends StatefulWidget {
  final int type;
  NewFriendOrGroupNotice(this.type);
  @override
  State<StatefulWidget> createState() => NewFriendOrGroupNoticeState();
}

//好友申请
class ApplicationItem extends StatelessWidget {
  ApplicationItem(this.application);
  final V2TimFriendApplication application;
  refuse(context) async {
    V2TimValueCallback<V2TimFriendOperationResult> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .refuseFriendApplication(
                type: application.type, userID: application.userID);
    if (res.code == 0) {
      Utils.toast("拒绝成功");
      getFriendApplication(context);
      Navigator.pop(context);
    } else {
      print(res.desc);
    }
  }

  accept(context) async {
    V2TimValueCallback<V2TimFriendOperationResult> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .acceptFriendApplication(
              type: application.type,
              userID: application.userID,
              responseType: 1, //加双向好友
            );
    if (res.code == 0) {
      Utils.toast("添加成功");
      await getFriendApplication(context); // 解决好友通知不清理的问题
      Navigator.pop(context);
    } else {
      print(res.desc);
    }
  }

  getFriendApplication(context) async {
    V2TimValueCallback<V2TimFriendApplicationResult> data =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendApplicationList();
    if (data.code == 0) {
      print("dangqianshenqing${data.data!.friendApplicationList!.length}");
      if (data.data!.friendApplicationList!.length > 0) {
        Provider.of<FriendApplicationModel>(context, listen: false)
            .setFriendApplicationResult(data.data!.friendApplicationList);
      } else {
        Provider.of<FriendApplicationModel>(context, listen: false).clear();
        // Provider.of<FriendApplicationModel>(context, listen: false) 老逻辑
        //     .setFriendApplicationResult(List.empty(growable: true));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("当前申请${application.toJson()}");
    return Material(
      child: Ink(
        color: CommonColors.getWitheColor(),
        child: InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            height: 50,
            child: Row(
              children: [
                Avatar(
                  width: 30,
                  height: 30,
                  radius: 2,
                  avtarUrl:
                      application.faceUrl == '' || application.faceUrl == null
                          ? 'images/logo.png'
                          : application.faceUrl,
                ),
                Container(
                  child: Text("${application.userID}申请加您为好友"),
                  padding: EdgeInsets.only(left: 10),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Text(
                            "同意",
                            style: TextStyle(
                              color: CommonColors.getThemeColor(),
                            ),
                          ),
                        ),
                        onTap: () {
                          accept(context);
                        },
                      ),
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Text(
                            "拒绝",
                            style: TextStyle(
                              color: CommonColors.getTextWeakColor(),
                            ),
                          ),
                        ),
                        onTap: () {
                          refuse(context);
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//群申请
class GroupApplicationItem extends StatelessWidget {
  GroupApplicationItem(this.application);
  final V2TimGroupApplication application;
  refuse(context) async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .refuseGroupApplication(
          groupID: application.groupID,
          reason: "",
          fromUser: application.fromUser!,
          toUser: application.toUser!,
          addTime: application.addTime!,
          type: application.type,
        );
    if (res.code == 0) {
      Utils.toast("拒绝成功");
      getGroupApplicationList(context);
      back(context);
    } else {
      print(res.desc);
    }
  }

  accept(context) async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .acceptGroupApplication(
          groupID: application.groupID,
          toUser: application.toUser!,
          fromUser: application.fromUser!,
          addTime: application.addTime,
          type: application.type,
        );
    if (res.code == 0) {
      Utils.toast("添加成功");
      getGroupApplicationList(context);
      back(context);
    } else {
      Utils.toast("加群失败 ${res.desc}");
    }
    print("同意加群${res.code}");
  }

  back(context) {
    Navigator.pop(context);
  }

  getGroupApplicationList(context) async {
    // 获取加群申请
    V2TimValueCallback<V2TimGroupApplicationResult> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupApplicationList();
    if (res.code == 0) {
      if (res.data!.groupApplicationList!.length > 0) {
        Provider.of<GroupApplicationModel>(context, listen: false)
            .setGroupApplicationResult(res.data!.groupApplicationList);
      } else {
        Provider.of<GroupApplicationModel>(context, listen: false)
            .setGroupApplicationResult(new List.empty(growable: true));
      }
    } else {
      print("获取加群申请失败${res.desc}");
    }
  }

  @override
  Widget build(Object context) {
    print("当前申请${application.toJson()}");
    return Material(
      child: Ink(
        color: CommonColors.getWitheColor(),
        child: InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            height: 50,
            child: Row(
              children: [
                Avatar(
                  width: 30,
                  height: 30,
                  radius: 2,
                  avtarUrl: application.fromUserFaceUrl == '' ||
                          application.fromUserFaceUrl == null
                      ? 'images/logo.png'
                      : application.fromUserFaceUrl,
                ),
                Container(
                  child:
                      Text("${application.fromUser}申请加入${application.groupID}"),
                  padding: EdgeInsets.only(left: 10),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: application.handleStatus ==
                            GroupApplicationHandleStatus
                                .V2TIM_GROUP_APPLICATION_HANDLE_STATUS_UNHANDLED
                        ? [
                            InkWell(
                              child: Container(
                                padding: EdgeInsets.only(left: 5, right: 5),
                                child: Text(
                                  "同意",
                                  style: TextStyle(
                                    color: CommonColors.getThemeColor(),
                                  ),
                                ),
                              ),
                              onTap: () {
                                accept(context);
                              },
                            ),
                            InkWell(
                              child: Container(
                                padding: EdgeInsets.only(left: 5, right: 5),
                                child: Text(
                                  "拒绝",
                                  style: TextStyle(
                                    color: CommonColors.getTextWeakColor(),
                                  ),
                                ),
                              ),
                              onTap: () {
                                refuse(context);
                              },
                            )
                          ]
                        : application.handleStatus ==
                                GroupApplicationHandleStatus
                                    .V2TIM_GROUP_APPLICATION_HANDLE_STATUS_HANDLED_BY_SELF
                            ? application.handleResult ==
                                    GroupApplicationHandleResult
                                        .V2TIM_GROUP_APPLICATION_HANDLE_RESULT_AGREE
                                ? [
                                    Text(
                                      "已同意",
                                      style: TextStyle(
                                        color: CommonColors.getTextWeakColor(),
                                      ),
                                    )
                                  ]
                                : [
                                    Text(
                                      "已拒绝",
                                      style: TextStyle(
                                        color: CommonColors.getTextWeakColor(),
                                      ),
                                    )
                                  ]
                            : application.handleStatus ==
                                    GroupApplicationHandleStatus
                                        .V2TIM_GROUP_APPLICATION_HANDLE_STATUS_HANDLED_BY_OTHER
                                ? application.handleResult ==
                                        GroupApplicationHandleResult
                                            .V2TIM_GROUP_APPLICATION_HANDLE_RESULT_AGREE
                                    ? [
                                        Text(
                                          "他人已同意",
                                          style: TextStyle(
                                            color:
                                                CommonColors.getTextWeakColor(),
                                          ),
                                        )
                                      ]
                                    : [
                                        Text(
                                          "他人已拒绝",
                                          style: TextStyle(
                                            color:
                                                CommonColors.getTextWeakColor(),
                                          ),
                                        )
                                      ]
                                : [],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NewFriendOrGroupNoticeState extends State<NewFriendOrGroupNotice> {
  int? type;
  void initState() {
    this.type = widget.type;
    super.initState();
  }

  setApplicationAsread() {
    TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .setGroupApplicationRead()
        .then((V2TimCallback value) {
      if (value.code == 0) {
        print("设置申请已读成功。");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<V2TimFriendApplication> applicationList =
        Provider.of<FriendApplicationModel>(context).friendApplicationList;
    List<V2TimGroupApplication> groupApplicationList =
        Provider.of<GroupApplicationModel>(context).groupApplicationList;
    if (groupApplicationList.isNotEmpty) {
      setApplicationAsread();
    }
    return Scaffold(
      appBar: AppBar(
        title: type == 1 ? Text('新的好友申请') : Text('新的加群申请'),
        backgroundColor: CommonColors.getThemeColor(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: CommonColors.getGapColor(),
                child: type == 1
                    ? applicationList.length > 0
                        ? ListView(
                            children: applicationList
                                .map((e) => ApplicationItem(e))
                                .toList(),
                          )
                        : Center(
                            child: Text(
                              '暂无新的申请',
                              style: TextStyle(
                                  color: CommonColors.getTextWeakColor()),
                            ),
                          )
                    : groupApplicationList.length > 0
                        ? ListView(
                            children: groupApplicationList
                                .map((e) => GroupApplicationItem(e))
                                .toList(),
                          )
                        : Center(
                            child: Text(
                              '暂无新的申请',
                              style: TextStyle(
                                  color: CommonColors.getTextWeakColor()),
                            ),
                          ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
