import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:im_api_example/utils/toast.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

typedef OnSelect(List<String> data);
typedef OnSelectItemChange(String groupID);

class GroupSelector extends StatefulWidget {
  final OnSelect onSelect;
  final bool switchSelectType;
  final List<String> value;
  GroupSelector(
      {required this.onSelect,
      this.switchSelectType = true,
      required this.value});

  @override
  State<StatefulWidget> createState() => GroupSelectorState();
}

class GroupItem extends StatefulWidget {
  final bool switchSelectType;
  final OnSelectItemChange onSelectItemChange;
  final V2TimGroupInfo info;
  final List<String> selected;
  GroupItem(
    this.switchSelectType,
    this.info,
    this.selected, {
    required this.onSelectItemChange,
  });

  @override
  State<StatefulWidget> createState() => GroupItemState();
}

class GroupItemState extends State<GroupItem> {
  bool itemSelect = false;
  List<String> selected = List.empty(growable: true);
  void initState() {
    super.initState();
    setState(() {
      selected = widget.selected;
      itemSelect = widget.selected.contains(widget.info.groupID);
    });
  }

  onItemTap(String groupID, [bool? data]) {
    if (widget.switchSelectType) {
      // 单选
      if (widget.selected.length > 0) {
        String selectedGroupID = widget.selected.first;
        if (selectedGroupID != groupID) {
          Utils.toast("单选只能选一个呀");
          return;
        }
      }
    }
    if (data != null) {
      this.setState(() {
        itemSelect = data;
      });
    } else {
      this.setState(() {
        itemSelect = !itemSelect;
      });
    }
    widget.onSelectItemChange(groupID);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: InkWell(
        onTap: () {
          onItemTap(widget.info.groupID);
        },
        child: Row(
          children: [
            Checkbox(
              value: itemSelect,
              onChanged: (data) {
                onItemTap(widget.info.groupID, data);
              },
            ),
            Expanded(
              child: Text(
                  "GroupID：${widget.info.groupType} ${widget.info.groupID}"),
            )
          ],
        ),
      ),
    );
  }
}

class GroupList extends StatefulWidget {
  final bool switchSelectType;
  final List<V2TimGroupInfo> users;
  final OnSelect onSelect;
  final List<String> value;
  GroupList(this.switchSelectType, this.users, this.onSelect, this.value);
  @override
  State<StatefulWidget> createState() => GroupListState();
}

class GroupListState extends State<GroupList> {
  void initState() {
    super.initState();
    setState(() {
      selected = widget.value;
    });
  }

  List<String> selected = List.empty(growable: true);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      child: new ListView.builder(
        primary: true,
        shrinkWrap: true,
        itemCount: widget.users.length,
        itemBuilder: (context, index) {
          return GroupItem(
            widget.switchSelectType,
            widget.users[index],
            selected,
            onSelectItemChange: (groupID) {
              if (selected.contains(groupID)) {
                selected.remove(groupID);
              } else {
                selected.add(groupID);
              }
              widget.onSelect(selected);
            },
          );
        },
      ),
    );
  }
}

class GroupSelectorState extends State<GroupSelector> {
  void initState() {
    super.initState();
    setState(() {
      selected = widget.value;
    });
  }

  List<String> selected = List.empty(growable: true);
  List<V2TimGroupInfo> groupList = List.empty();

  Future<List<V2TimGroupInfo>?> getFrienList() async {
    await EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.black,
    );
    V2TimValueCallback<List<V2TimGroupInfo>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getGroupManager()
        .getJoinedGroupList();
    EasyLoading.dismiss();
    if (res.code != 0) {
      Utils.toastError(res.code, res.desc);
    } else {
      setState(() {
        groupList = res.data!;
      });
      return res.data;
    }
  }

  AlertDialog dialogShow(context) {
    AlertDialog dialog = AlertDialog(
      title: Text('群组选择（${widget.switchSelectType ? '单选' : '多选'}）'),
      contentPadding: EdgeInsets.zero,
      content: GroupList(widget.switchSelectType, groupList, (data) {
        setState(() {
          selected = data;
        });
      }, selected),
      actions: [
        ElevatedButton(
          onPressed: () {
            widget.onSelect(selected);
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
      onPressed: () async {
        List<V2TimGroupInfo>? fl = await this.getFrienList();
        if (fl != null) {
          if (fl.length > 0) {
            showDialog<void>(
              context: context,
              builder: (context) => dialogShow(context),
            );
          } else {
            Utils.toast("请先加入群组");
          }
        }
      },
      child: Text("选择群组"),
    );
  }
}
