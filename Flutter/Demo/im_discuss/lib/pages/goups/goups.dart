import 'package:discuss/common/hextocolor.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:discuss/common/avatar.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/pages/conversion/conversion.dart';

class Groups extends StatefulWidget {
  const Groups({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => GroupsState();
}

class GroupItem extends StatelessWidget {
  const GroupItem(this.groupInfo, {Key? key}) : super(key: key);
  final V2TimGroupInfo groupInfo;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Conversion('group_${groupInfo.groupID}'),
          ),
        );
      },
      child: Container(
        height: 50,
        child: Row(
          children: [
            Container(
              child: Avatar(
                avtarUrl: groupInfo.faceUrl == '' || groupInfo.faceUrl == null
                    ? 'images/logo.png'
                    : groupInfo.faceUrl,
                width: 30,
                height: 30,
                radius: 0,
              ),
              padding: const EdgeInsets.only(
                right: 10,
              ),
            ),
            Expanded(
              child: Text(groupInfo.groupName!),
            )
          ],
        ),
        margin: const EdgeInsets.only(top: 10),
        color: CommonColors.getWitheColor(),
        padding: const EdgeInsets.all(10),
      ),
    );
  }
}

class GroupsState extends State<Groups> {
  GroupsState() {
    getJoinedGroupList();
  }
  List<V2TimGroupInfo> groupList = List.empty(growable: true);
  getJoinedGroupList() async {
    V2TimValueCallback<List<V2TimGroupInfo>> data = await TencentImSDKPlugin
        .v2TIMManager
        .getGroupManager()
        .getJoinedGroupList();
    if (data.code == 0) {
      List<V2TimGroupInfo>? list = data.data;
      if (list != null && list.isNotEmpty) {
        setState(() {
          groupList = list;
        });
      }
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
        title: const Text(
          '群聊',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: CommonColors.getThemeColor(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: CommonColors.getGapColor(),
                child: groupList.isNotEmpty
                    ? ListView(
                        children: groupList.map((e) => GroupItem(e)).toList(),
                      )
                    : Center(
                        child: Text(
                          "暂未加入群组",
                          style: TextStyle(
                            color: CommonColors.getTextWeakColor(),
                          ),
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
