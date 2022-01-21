import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/utils/commonUtils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_application_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_response_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/group_application_handle_result.dart';
import 'package:tencent_im_sdk_plugin/enum/group_application_handle_status.dart';
import 'package:tencent_im_sdk_plugin/enum/group_application_type_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:discuss/common/avatar.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/provider/friendapplication.dart';
import 'package:discuss/provider/groupapplication.dart';
import 'package:discuss/utils/toast.dart';

class NewFriendOrGroupNotice extends StatefulWidget {
  final int type;
  const NewFriendOrGroupNotice(this.type, {Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => NewFriendOrGroupNoticeState();
}

//好友申请
class ApplicationItem extends StatelessWidget {
  const ApplicationItem(this.application, {Key? key}) : super(key: key);
  final V2TimFriendApplication application;
  refuse(context) async {
    V2TimValueCallback<V2TimFriendOperationResult> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .refuseFriendApplication(
                type: FriendApplicationTypeEnum.V2TIM_FRIEND_APPLICATION_BOTH,
                userID: application.userID);
    if (res.code == 0) {
      Utils.toast("拒绝成功");
      getFriendApplication(context);
      Navigator.pop(context);
    } else {
      Utils.log(res.desc);
    }
  }

  accept(context) async {
    V2TimValueCallback<V2TimFriendOperationResult> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .acceptFriendApplication(
              type: FriendApplicationTypeEnum.V2TIM_FRIEND_APPLICATION_BOTH,
              userID: application.userID,
              responseType: FriendResponseTypeEnum
                  .V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD, //加双向好友
            );
    if (res.code == 0) {
      Utils.toast("添加成功");
      await getFriendApplication(context); // 解决好友通知不清理的问题
      Navigator.pop(context);
    } else {
      Utils.log(res.desc);
    }
  }

  getFriendApplication(context) async {
    V2TimValueCallback<V2TimFriendApplicationResult> data =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendApplicationList();
    if (data.code == 0) {
      Utils.log("dangqianshenqing${data.data!.friendApplicationList!.length}");
      if (data.data!.friendApplicationList!.isNotEmpty) {
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
    Utils.log("当前申请${application.toJson()}");
    return Material(
      child: Ink(
        color: CommonColors.getWitheColor(),
        child: InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
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
                  padding: const EdgeInsets.only(left: 10),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        child: Container(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Text(
                            "同意",
                            style: TextStyle(
                              color: CommonColors.getThemeBlueColor(),
                            ),
                          ),
                        ),
                        onTap: () {
                          accept(context);
                        },
                      ),
                      InkWell(
                        child: Container(
                          padding: const EdgeInsets.only(left: 5, right: 5),
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
  const GroupApplicationItem(this.application, {Key? key}) : super(key: key);
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
          type: GroupApplicationTypeEnum.V2TIM_GROUP_APPLICATION_GET_TYPE_JOIN,
        );
    if (res.code == 0) {
      Utils.toast("拒绝成功");
      await getGroupApplicationList(context);
      back(context);
    } else {
      Utils.log(res.desc);
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
          type: GroupApplicationTypeEnum.V2TIM_GROUP_APPLICATION_GET_TYPE_JOIN,
        );
    if (res.code == 0) {
      Utils.toast("添加成功");
      await getGroupApplicationList(context);
      back(context);
    } else {
      Utils.toast("加群失败 ${res.desc}");
    }
    Utils.log("同意加群${res.code}");
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
      if (res.data!.groupApplicationList!.isNotEmpty) {
        Provider.of<GroupApplicationModel>(context, listen: false)
            .setGroupApplicationResult(
                List.castFrom(res.data!.groupApplicationList!));
      } else {
        Provider.of<GroupApplicationModel>(context, listen: false)
            .setGroupApplicationResult(List.empty(growable: true));
      }
    } else {
      Utils.log("获取加群申请失败${res.desc}");
    }
  }

  @override
  Widget build(Object context) {
    Utils.log("当前申请${application.toJson()}");
    return Material(
      child: Ink(
        color: CommonColors.getWitheColor(),
        child: InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
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
                  padding: const EdgeInsets.only(left: 10),
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
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: const Text(
                                  "同意",
                                  style: TextStyle(
                                    color: Color(0xFF147AFF),
                                  ),
                                ),
                              ),
                              onTap: () {
                                accept(context);
                              },
                            ),
                            InkWell(
                              child: Container(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: const Text(
                                  "拒绝",
                                  style: TextStyle(color: Color(0xFFFF584C)),
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
  @override
  void initState() {
    type = widget.type;
    super.initState();
  }

  setApplicationAsread() {
    TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .setGroupApplicationRead()
        .then((V2TimCallback value) {
      if (value.code == 0) {
        Utils.log("设置申请已读成功。");
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
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        shadowColor: hexToColor("ececec"),
        elevation: 1,
        title: type == 1
            ? Text(
                '新的好友申请',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: CommonUtils.adaptFontSize(30)),
              )
            : Text(
                '新的加群申请',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: CommonUtils.adaptFontSize(30)),
              ),
        backgroundColor: CommonColors.getThemeColor(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: CommonColors.getGapColor(),
                child: type == 1
                    ? applicationList.isNotEmpty
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
                    : groupApplicationList.isNotEmpty
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
