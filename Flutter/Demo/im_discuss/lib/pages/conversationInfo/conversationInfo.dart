import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/pages/allmembers/allmembers.dart';
import 'package:discuss/utils/commonUtils.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_role.dart';
import 'package:tencent_im_sdk_plugin/enum/group_type.dart';
import 'package:tencent_im_sdk_plugin/enum/group_add_opt_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:discuss/common/avatar.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/pages/contact/choosecontact.dart';

import 'package:discuss/pages/profile/component/groupprofilepanel.dart';
import 'package:discuss/pages/profile/component/listgap.dart';
import 'package:discuss/utils/toast.dart';

class ConversationInfo extends StatefulWidget {
  const ConversationInfo(this.id, this.type, {Key? key}) : super(key: key);
  final String id;
  final int type;
  @override
  State<StatefulWidget> createState() {
    return ConversationInfoState();
  }
}

class GroupMemberProfileTitle extends StatelessWidget {
  const GroupMemberProfileTitle(this.memberInfo, this.groupInfo, this.getDetail,
      {Key? key})
      : super(key: key);
  final V2TimGroupMemberInfoResult memberInfo;
  final V2TimGroupInfoResult groupInfo;
  final Function getDetail;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllMembers(groupInfo),
              ),
            ).then((res) {
              getDetail();
            });
          },
          child: Container(
            margin: const EdgeInsets.only(right: 10, left: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CommonColors.getBorderColor(),
                  width: 1,
                ),
              ),
            ),
            height: 40,
            child: Row(
              children: [
                const Text("群成员"),
                Expanded(child: Container()),
                Text("${groupInfo.groupInfo!.memberCount}人"),
                const Icon(Icons.keyboard_arrow_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MemberListOverview extends StatelessWidget {
  const MemberListOverview(this.memberInfo, this.groupInfo, {Key? key})
      : super(key: key);
  final V2TimGroupMemberInfoResult? memberInfo;
  final V2TimGroupInfoResult groupInfo;
  getShowName(V2TimGroupMemberFullInfo info) {
    String name = '';
    if (info.friendRemark != null && info.friendRemark != '') {
      name = info.friendRemark!;
      return name;
    }
    if (info.nickName != null && info.nickName != '') {
      name = info.nickName!;
      return name;
    }
    if (info.nameCard != null && info.nameCard != '') {
      name = info.nameCard!;
      return name;
    }
    if (info.userID != '') {
      name = info.userID;
      return name;
    }
    return name;
  }

  List<Widget> renderMember(context) {
    List<Widget> member = memberInfo!.memberInfoList!
        .sublist(
          0,
          memberInfo!.memberInfoList!.length > 5
              ? 5
              : memberInfo!.memberInfoList!.length,
        )
        .map(
          (e) => Column(
            children: [
              Avatar(
                width: 30,
                height: 30,
                avtarUrl: e!.faceUrl == '' || e.faceUrl == null
                    ? 'images/logo.png'
                    : e.faceUrl,
                radius: 2,
              ),
              Text(
                getShowName(e),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        )
        .toList();
    // 如果是好友工作群允许邀请好友进群
    if ((groupInfo.groupInfo!.role ==
                GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN ||
            groupInfo.groupInfo!.role ==
                GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER) &&
        groupInfo.groupInfo!.groupType == GroupType.Work) {
      member.add(Column(
        children: [
          SizedBox(
              child: IconButton(
                  icon: Icon(
                    Icons.add_box,
                    color: CommonColors.getTextWeakColor(),
                  ),
                  // iconSize: 40,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChooseContact(
                          6,
                          groupInfo.groupInfo!.groupID,
                        ),
                      ),
                    );
                  }),
              width: 40,
              height: 40)
        ],
      ));
    }
    return member;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 80,
      child: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          childAspectRatio: 1,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        children: renderMember(context),
      ),
    );
  }
}

// add(
//               Container(
//                 child: Icon(Icons.add_alarm_outlined),
//                 width: 30,
//                 height: 30,
//               ),
//             )
class GroupMemberProfile extends StatelessWidget {
  const GroupMemberProfile(this.memberInfo, this.groupInfo, this.getDetail,
      {Key? key})
      : super(key: key);
  final V2TimGroupMemberInfoResult memberInfo;
  final V2TimGroupInfoResult groupInfo;
  final Function getDetail;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GroupMemberProfileTitle(memberInfo, groupInfo, getDetail),
        MemberListOverview(memberInfo, groupInfo),
      ],
    );
  }
}

class GroupTypeAndAddInfo extends StatelessWidget {
  const GroupTypeAndAddInfo(this.groupInfo, {Key? key}) : super(key: key);
  final V2TimGroupInfoResult? groupInfo;
  getGroupType() {
    String name = '';
    if (groupInfo!.groupInfo!.groupType == GroupType.AVChatRoom) {
      name = '直播群';
    }
    if (groupInfo!.groupInfo!.groupType == GroupType.Meeting) {
      name = '临时会议群';
    }
    if (groupInfo!.groupInfo!.groupType == GroupType.Public) {
      name = '陌生人社交群';
    }
    if (groupInfo!.groupInfo!.groupType == GroupType.Work) {
      name = '好友工作群';
    }
    return name;
  }

  getAddType() {
    int? type = groupInfo!.groupInfo!.groupAddOpt;
    String name = '';

    if (type == GroupAddOptType.V2TIM_GROUP_ADD_ANY) {
      name = '任何人可以加入';
    }
    if (type == GroupAddOptType.V2TIM_GROUP_ADD_AUTH) {
      name = '需要管理员审批';
    }
    if (type == GroupAddOptType.V2TIM_GROUP_ADD_FORBID) {
      name = '禁止加群';
    }
    return name;
  }

  getRoleType() {
    int? type = groupInfo!.groupInfo!.role;
    String name = '';
    if (type == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN) {
      name = '群管理员';
    }
    if (type == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_MEMBER) {
      name = '群成员';
    }
    if (type == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER) {
      name = '群主';
    }
    if (type == GroupMemberRoleType.V2TIM_GROUP_MEMBER_UNDEFINED) {
      name = '身份未知';
    }
    return name;
  }

  bool canDissmiss() {
    String groupType = groupInfo!.groupInfo!.groupType;
    int? role = groupInfo!.groupInfo!.role;
    Utils.log(
        "groupType $groupType $role ${groupType != GroupType.Work} ${(groupType != GroupType.Work && (role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN || role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER))}");
    return (groupType == GroupType.Work &&
            role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN) ||
        (groupType != GroupType.Work &&
            (role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN ||
                role == GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER));
  }

  Future<bool?> showDeleteConfirmDialog(context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("提示"),
          content: const Text("您确定要解散当前群组吗?"),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            ElevatedButton(
              child: const Text("解散"),
              onPressed: () {
                //关闭对话框并返回true
                Navigator.of(context).pop();
                TencentImSDKPlugin.v2TIMManager
                    .dismissGroup(groupID: groupInfo!.groupInfo!.groupID)
                    .then((res) {
                  if (res.code == 0) {
                    Utils.toast("解散群组成功");
                    // 退出到最新到界面
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  } else {
                    Utils.toast("解散群组失败${res.code}  ${res.desc}");
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget renderDismssGroup(context) {
    return canDissmiss()
        ? InkWell(
            onTap: () {
              showDeleteConfirmDialog(context);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: CommonColors.getBorderColor(),
                  ),
                ),
              ),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: const [
                  Text("解散本群"),
                ],
              ),
            ),
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    if (groupInfo == null) {
      return Container();
    }

    return Column(
      children: [
        InkWell(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: CommonColors.getBorderColor(),
                ),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                const Text('群身份'),
                Expanded(
                  child: Container(),
                ),
                Text(getRoleType())
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: CommonColors.getBorderColor(),
                ),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                const Text('群类型'),
                Expanded(
                  child: Container(),
                ),
                Text(getGroupType())
              ],
            ),
          ),
        ),
        renderDismssGroup(context),
        InkWell(
          onTap: () {
            if (GroupType.Public != groupInfo!.groupInfo!.groupType) {
              Utils.toast("非public群不可更改入群方式");
              return;
            }
            if (GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_MEMBER ==
                    groupInfo!.groupInfo!.role ||
                GroupMemberRoleType.V2TIM_GROUP_MEMBER_UNDEFINED ==
                    groupInfo!.groupInfo!.role) {
              Utils.toast("非群主或者管理员");
              return;
            }
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min, // 设置最小的弹出
                    children: <Widget>[
                      ListTile(
                        title: const Text(
                          "任何人可以加入",
                          textAlign: TextAlign.center,
                          // style: TextStyle(color: CommonColors.getThemeColor()),
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();

                          TencentImSDKPlugin.v2TIMManager
                              .getGroupManager()
                              .setGroupInfo(
                                info: V2TimGroupInfo.fromJson(
                                  {
                                    "groupID": groupInfo!.groupInfo!.groupID,
                                    "addOpt":
                                        GroupAddOptType.V2TIM_GROUP_ADD_ANY,
                                  },
                                ),
                              )
                              .then((value) {
                            if (value.code == 0) {
                              Utils.toast("设置成功");
                              Navigator.pop(context);
                            } else {
                              Utils.toast("${value.code} ${value.desc}");
                            }
                          });
                        },
                      ),
                      ListTile(
                        title: const Text(
                          "需要管理员审批",
                          textAlign: TextAlign.center,
                          // style: TextStyle(color: CommonColors.getThemeColor()),
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          TencentImSDKPlugin.v2TIMManager
                              .getGroupManager()
                              .setGroupInfo(
                                info: V2TimGroupInfo.fromJson(
                                  {
                                    "groupID": groupInfo!.groupInfo!.groupID,
                                    "groupType":
                                        groupInfo!.groupInfo!.groupType,
                                    "groupAddOpt":
                                        GroupAddOptType.V2TIM_GROUP_ADD_AUTH,
                                  },
                                ),
                              )
                              .then((value) {
                            if (value.code == 0) {
                              Utils.toast("设置成功");
                              Navigator.pop(context);
                            } else {
                              Utils.toast("${value.code} ${value.desc}");
                            }
                          });
                        },
                      ),
                      ListTile(
                        title: const Text(
                          "禁止加群",
                          textAlign: TextAlign.center,
                          // style: TextStyle(color: CommonColors.getThemeColor()),
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          TencentImSDKPlugin.v2TIMManager
                              .getGroupManager()
                              .setGroupInfo(
                                info: V2TimGroupInfo.fromJson(
                                  {
                                    "groupID": groupInfo!.groupInfo!.groupID,
                                    "addOpt":
                                        GroupAddOptType.V2TIM_GROUP_ADD_FORBID,
                                  },
                                ),
                              )
                              .then((value) {
                            if (value.code == 0) {
                              Utils.toast("设置成功");
                              Navigator.pop(context);
                            } else {
                              Utils.toast("${value.code} ${value.desc}");
                            }
                          });
                        },
                      )
                    ],
                  );
                });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                const Text('加群方式'),
                Expanded(
                  child: Container(),
                ),
                Text(getAddType()),
                const Icon(Icons.keyboard_arrow_right_outlined)
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ExitGroup extends StatelessWidget {
  const ExitGroup(this.groupInfo, {Key? key}) : super(key: key);
  final V2TimGroupInfoResult? groupInfo;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                // 先删一下会话

                V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
                    .quitGroup(groupID: groupInfo!.groupInfo!.groupID);
                V2TimCallback deleteRes = await TencentImSDKPlugin.v2TIMManager
                    .getConversationManager()
                    .deleteConversation(
                        conversationID:
                            "group_${groupInfo!.groupInfo!.groupID}");
                if (res.code == 0) {
                  Utils.toast("退出成功");
                  if (deleteRes.code == 0) {
                    Utils.log("删除会话成功");
                  } else {
                    Utils.log("删除会话失败 ${deleteRes.code} ${deleteRes.desc}");
                  }
                  Navigator.pop(context);
                } else {
                  Utils.toast("退出失败${res.code} ${res.desc} ");
                }
              },
              child: const Text("删除并退出"),
            ),
          )
        ],
      ),
    );
  }
}

class ConversationInfoState extends State<ConversationInfo> {
  @override
  void initState() {
    super.initState();
    id = widget.id;
    type = widget.type;
    groupInfo = V2TimGroupInfoResult(
        groupInfo: V2TimGroupInfo(groupID: '', groupType: ''));
    memberInfo = V2TimGroupMemberInfoResult();
    memberInfo.memberInfoList = List.empty();
    Utils.log("当前会话id $id");
    getDetail();
  }

  late String id;
  late int type;
  late V2TimGroupInfoResult groupInfo;
  late V2TimGroupMemberInfoResult memberInfo;
  // 获取用户或者群的详细资料
  getDetail() async {
    V2TimValueCallback<List<V2TimGroupInfoResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupsInfo(groupIDList: [id]);
    if (res.code == 0) {
      setState(() {
        groupInfo = res.data![0];
      });
    } else {
      Utils.toast("获取群信息失败 ${res.code} ${res.desc}");
    }

    Utils.log("当前用户详情${res.data![0].groupInfo!.toJson()}");
    String groupID = res.data![0].groupInfo!.groupID;
    V2TimValueCallback<V2TimGroupMemberInfoResult> list =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupMemberList(
              groupID: groupID,
              filter: GroupMemberFilterTypeEnum.V2TIM_GROUP_MEMBER_FILTER_ALL,
              nextSeq: "0", //第一次从0开始拉
            );
    if (list.code == 0) {
      Utils.log(
          "list.data.memberInfoList.length:${list.data!.memberInfoList!.length}");

      setState(() {
        groupInfo = res.data![0];
        memberInfo = list.data!;
      });
    } else {
      Utils.toast("获取群成员信息失败 ${list.code} ${list.desc}");
    }
  }

  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        shadowColor: hexToColor("ececec"),
        elevation: 1,
        backgroundColor: CommonColors.getThemeColor(),
        title: Text(
          "详细资料",
          style: TextStyle(
              color: Colors.black, fontSize: CommonUtils.adaptFontSize(30)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            GroupProfilePanel(groupInfo),
            const ListGap(),
            GroupMemberProfile(memberInfo, groupInfo, getDetail),
            const ListGap(),
            GroupTypeAndAddInfo(groupInfo),
            const ListGap(),
            Expanded(
              child: Container(),
            ),
            ExitGroup(groupInfo)
          ],
        ),
      ),
    );
  }
}
