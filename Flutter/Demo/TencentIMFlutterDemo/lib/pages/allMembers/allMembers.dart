import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';

import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin_example/common/avatar.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:tencent_im_sdk_plugin_example/utils/toast.dart';

class AllMembers extends StatefulWidget {
  final V2TimGroupInfoResult groupInfo;
  AllMembers(this.groupInfo);

  @override
  State<StatefulWidget> createState() => AllMembersState();
}

class AllMembersState extends State<AllMembers> {
  late List<V2TimGroupMemberFullInfo?>? memberList;

  void initState() {
    super.initState();
    getAllgroupMember();
    Utils.toast("长按可进行群成员踢出");
  }

  getAllgroupMember() {
    TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .getGroupMemberList(
          groupID: widget.groupInfo.groupInfo!.groupID,
          filter: GroupMemberFilterType.V2TIM_GROUP_MEMBER_FILTER_ALL,
          nextSeq: "0", //第一次拉填0
        )
        .then((res) {
      List<V2TimGroupMemberFullInfo?>? list = res.data!.memberInfoList;
      setState(() {
        memberList = list;
      });
    });
  }

  Future<bool?> showDeleteConfirmDialog(context, userID) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("提示"),
          content: Text("确定将该人退出群组吗?"),
          actions: <Widget>[
            ElevatedButton(
              child: Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            ElevatedButton(
              child: Text("确定"),
              onPressed: () {
                //关闭对话框并返回true
                Navigator.of(context).pop();
                TencentImSDKPlugin.v2TIMManager
                    .getGroupManager()
                    .kickGroupMember(
                  groupID: widget.groupInfo.groupInfo!.groupID,
                  memberList: [userID],
                ).then((res) {
                  if (res.code == 0) {
                    getAllgroupMember();
                  } else {
                    Utils.toast("踢人出群失败 ${res.code} ${res.desc}");
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (memberList == null) {
      return Center(
        child: LoadingIndicator(
          indicatorType: Indicator.lineSpinFadeLoader,
          color: Colors.black26,
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('群成员'),
        backgroundColor: CommonColors.getThemeColor(),
      ),
      body: SafeArea(
        child: Container(
          child: GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            children: memberList!
                .map(
                  (e) => GestureDetector(
                    onLongPress: () {
                      showDeleteConfirmDialog(context, e!.userID);
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Avatar(
                            width: 50,
                            height: 50,
                            avtarUrl: e!.faceUrl == null || e.faceUrl == ''
                                ? 'images/logo.png'
                                : e.faceUrl,
                            radius: 0,
                          ),
                          Text(
                            e.userID,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
