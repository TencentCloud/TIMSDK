import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/enum/group_change_info_type.dart';
import 'package:tencent_im_sdk_plugin/enum/group_tips_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_change_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class SystemMessage extends StatefulWidget {
  const SystemMessage(this.message, {Key? key}) : super(key: key);
  final V2TimMessage message;
  @override
  State<StatefulWidget> createState() => SystemMessageState();
}

class SystemMessageState extends State<SystemMessage> {
  @override
  void initState() {
    message = widget.message;

    super.initState();
  }

  V2TimMessage? message;
  getMemberNickName(V2TimGroupMemberInfo e) {
    return e.friendRemark == null || e.friendRemark == ''
        ? e.nickName == null || e.nickName == ''
            ? e.userID
            : e.nickName
        : e.friendRemark;
  }

  getOpUserNick(V2TimGroupMemberInfo opUser) {
    return opUser.friendRemark == null || opUser.friendRemark == ''
        ? opUser.nickName == null || opUser.nickName == ''
            ? opUser.userID
            : opUser.nickName
        : opUser.friendRemark;
  }

  getGroupChangeType(V2TimGroupChangeInfo info) {
    int? type = info.type;
    var value = info.value;
    String s = '';
    if (type == GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_CUSTOM) {
      s = '自定义字段';
      value = '';
    } else if (type ==
        GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_FACE_URL) {
      s = '群头像';
      value = '';
    } else if (type ==
        GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION) {
      s = '群简介';
    } else if (type == GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_NAME) {
      s = '群名称';
    } else if (type ==
        GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION) {
      s = '群通知';
    } else if (type == GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER) {
      s = '群主';
      value = '';
    }
    return '$s"$value"';
  }

  showGroupTips() {
    int type = message!.groupTipsElem!.type;
    List<V2TimGroupMemberInfo?>? memberlist =
        message!.groupTipsElem!.memberList;
    V2TimGroupMemberInfo opUser = message!.groupTipsElem!.opMember;
    List<V2TimGroupChangeInfo?>? groupChangeInfoList =
        message!.groupTipsElem!.groupChangeInfoList;

    if (type == GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_JOIN) {
      //主动入群
      return Column(
          children: memberlist!
              .map((e) => Text("用户${getMemberNickName(e!)}加入了群聊"))
              .toList());
    } else if (type == GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_INVITE) {
      //被邀请进群
      return Column(
        children: memberlist!
            .map((e) =>
                Text("${getOpUserNick(opUser)}邀请了${getMemberNickName(e!)}"))
            .toList(),
      );
    } else if (type ==
        GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE) {
      return Column(
        children: groupChangeInfoList!
            .map((e) =>
                Text("${getOpUserNick(opUser)}修改${getGroupChangeType(e!)}"))
            .toList(),
      );
    } else if (type == GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_QUIT) {
      return Text("${getOpUserNick(opUser)}退出群聊");
    } else {
      return Text('系统消息$type');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: showGroupTips(),
    );
  }
}
