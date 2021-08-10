import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

typedef OnGet(List<String> data);

class GroupMemberSelector extends StatefulWidget {
  final String groupID;
  final List<String> values;
  final OnGet onSelect;
  GroupMemberSelector(this.groupID, this.values, this.onSelect);
  @override
  State<StatefulWidget> createState() => GroupMemberSelectorState();
}

class GroupMemberSelectorState extends State<GroupMemberSelector> {
  List<String> groupMembers = List.empty(growable: true);
  List<String> groupMembersSelected = List.empty(growable: true);
  @override
  void initState() {
    super.initState();
  }

  getGroupMember() async {
    await EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.black,
    );
    V2TimValueCallback<V2TimGroupMemberInfoResult> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupMemberList(
              groupID: widget.groupID,
              filter: GroupMemberFilterType.V2TIM_GROUP_MEMBER_FILTER_ALL,
              nextSeq: "0",
            );
    EasyLoading.dismiss();
    List<String> groupMembersId = List.empty(growable: true);
    res.data!.memberInfoList!.forEach((element) {
      groupMembersId.add(element!.userID);
    });

    setState(() {
      groupMembers = groupMembersId;
    });
    showDialog<void>(
      context: context,
      builder: (context) => dialogShow(context),
    );
  }

  AlertDialog dialogShow(context) {
    AlertDialog dialog = AlertDialog(
      title: Text('选择群成员'),
      contentPadding: EdgeInsets.zero,
      content: MemberList(
        groupMembers,
        widget.values,
        (memberID) {
          if (groupMembersSelected.contains(memberID)) {
            groupMembersSelected.remove(memberID);
          } else {
            groupMembersSelected.add(memberID);
          }
          widget.onSelect(groupMembersSelected);
        },
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('确认'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('取消'),
        ),
      ],
    );
    return dialog;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(),
      child: Text("选择群成员"),
      onPressed: widget.groupID == ''
          ? null
          : () {
              this.getGroupMember();
            },
    );
  }
}

class MemberList extends StatefulWidget {
  final List<String> members;
  final List<String> value;
  final Onselect onSelect;
  MemberList(this.members, this.value, this.onSelect);
  @override
  State<StatefulWidget> createState() => MemberListState();
}

class MemberListState extends State<MemberList> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      child: new ListView.builder(
        primary: true,
        shrinkWrap: true,
        itemCount: widget.members.length,
        itemBuilder: (context, index) {
          return MemberItem(widget.members[index], widget.value, (memberID) {
            widget.onSelect(memberID);
          });
        },
      ),
    );
  }
}

typedef Onselect(String memberID);

class MemberItem extends StatefulWidget {
  final String memberID;
  final List<String> selected;
  final Onselect onSelect;
  MemberItem(this.memberID, this.selected, this.onSelect);

  @override
  State<StatefulWidget> createState() => MemberItemState();
}

class MemberItemState extends State<MemberItem> {
  bool itemSelect = false;
  void initState() {
    super.initState();
    if (widget.selected.contains(widget.memberID)) {
      setState(() {
        itemSelect = true;
      });
    }
  }

  onItemTap([bool? data]) {
    if (data != null) {
      this.setState(() {
        itemSelect = data;
      });
    } else {
      this.setState(() {
        itemSelect = !itemSelect;
      });
    }
    widget.onSelect(widget.memberID);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: InkWell(
        onTap: () {
          onItemTap();
        },
        child: Row(
          children: [
            Checkbox(
              value: itemSelect,
              onChanged: (data) {
                onItemTap(data);
              },
            ),
            Expanded(
              child: Text("memberID：${widget.memberID}"),
            )
          ],
        ),
      ),
    );
  }
}
