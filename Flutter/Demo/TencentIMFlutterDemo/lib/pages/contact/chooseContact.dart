import 'package:flutter/material.dart';

import 'package:tencent_im_sdk_plugin/enum/group_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin_example/common/avatar.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:tencent_im_sdk_plugin_example/common/hexToColor.dart';
import 'package:tencent_im_sdk_plugin_example/pages/conversion/conversion.dart';
import 'package:tencent_im_sdk_plugin_example/utils/toast.dart';

class ChooseContact extends StatefulWidget {
  ChooseContact(this.type, this.groupID);
  final int type; //1 个人，2群组 3,讨论组 4、聊天室
  final String? groupID;
  // 2、3、4均支持多选
  @override
  State<StatefulWidget> createState() => ChooseContactState(type, groupID);
}

class ShareDataWidget extends InheritedWidget {
  ShareDataWidget({required this.checkList, required Widget child})
      : super(child: child);
  final List<String> checkList;
  static ShareDataWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShareDataWidget>();
  }

  @override
  bool updateShouldNotify(covariant ShareDataWidget old) {
    return old.checkList != checkList;
  }
}

class ChooseContactState extends State<ChooseContact> {
  List<V2TimFriendInfo> list = [];

  Map<String, String> selectMap = new Map<String, String>();
  List<String> selectList = new List.empty(growable: true);
  late int type;
  late String? groupID;
  ChooseContactState(type, groupID) {
    this.type = type;
    this.groupID = groupID;
    getFriendList();
  }
  selectListChange(id) {
    setState(() {
      //这里还要区分type,单聊会话只能选一个联系人
      List<String> newList = selectList;
      if (type == 1 || type == 6) {
        if (newList.contains(id)) {
          newList.clear();
        } else {
          newList.clear();
          newList.add(id);
        }
      } else {
        if (selectList.contains(id)) {
          newList.remove(id);
        } else {
          newList.add(id);
        }
      }
      print("new List $newList");
      setState(() {
        selectList = newList;
      });
    });
  }

  getFriendList() async {
    V2TimValueCallback<List<V2TimFriendInfo>> data = await TencentImSDKPlugin
        .v2TIMManager
        .getFriendshipManager()
        .getFriendList();
    if (data.code == 0) {
      this.setState(() {
        list = data.data!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("选择联系人"),
        backgroundColor: CommonColors.getThemeColor(),
      ),
      body: SafeArea(
        child: ShareDataWidget(
          checkList: selectList,
          child: Container(
            color: CommonColors.getGapColor(),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: list
                        .map((e) => FriendItem(e, selectListChange, selectList))
                        .toList(),
                  ),
                ),
                Container(
                  height: 50,
                  color: hexToColor('FFFFFF'),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: Text(''),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: ElevatedButton(
                          child: Text("确定"),
                          onPressed: selectList.isEmpty
                              ? null
                              : () async {
                                  // 如果是单聊，直接打开会话，如果是群聊，需要先创建群
                                  if (type == 1) {
                                    Navigator.pushReplacement(
                                      context,
                                      new MaterialPageRoute(
                                        builder: (context) => Conversion(
                                          "c2c_${selectList[0]}",
                                        ),
                                      ),
                                    );
                                  } else {
                                    String groupYype = '';
                                    String name = '';
                                    switch (type) {
                                      case 2:
                                        groupYype = GroupType.Work;
                                        name = "Work";
                                        break;
                                      case 3:
                                        groupYype = GroupType.Public;
                                        name = "Public";
                                        break;
                                      case 4:
                                        groupYype = GroupType.Meeting;
                                        name = "Meeting";
                                        break;
                                      case 5:
                                        groupYype = GroupType.AVChatRoom;
                                        name = "AVChatRoom";
                                        break;
                                    }
                                    List<Map> newlist =
                                        new List.empty(growable: true);
                                    selectList.forEach((element) {
                                      Map user = new Map();
                                      user['userID'] = element;
                                      user['role'] = 200;
                                      newlist.add(user);
                                      print(newlist);
                                    });
                                    if (type != 6) {
                                      V2TimValueCallback<String> res =
                                          await TencentImSDKPlugin.v2TIMManager
                                              .getGroupManager()
                                              .createGroup(
                                                groupType: groupYype,
                                                groupName: "新创建$name",
                                                memberList: newlist,
                                              );
                                      if (res.code == 0) {
                                        String? groupId = res.data;
                                        Navigator.pushReplacement(
                                          context,
                                          new MaterialPageRoute(
                                            builder: (context) => Conversion(
                                              "group_$groupId",
                                            ),
                                          ),
                                        );
                                      } else {
                                        Utils.toast("${res.code} ${res.desc}");
                                      }
                                    } else {
                                      print("selectList $selectList");
                                      print("groupID $groupID");
                                      // 拉人进群
                                      TencentImSDKPlugin.v2TIMManager
                                          .getGroupManager()
                                          .inviteUserToGroup(
                                            groupID: groupID as String,
                                            userList: selectList,
                                          )
                                          .then((response) {
                                        if (response.code == 0) {
                                          //邀请成功
                                          Utils.toast("邀请成功");
                                          Navigator.pop(context);
                                        } else {
                                          //邀请失败

                                          Utils.toast(
                                              "${response.code} ${response.desc}");
                                        }
                                      });
                                    }
                                  }
                                },
                        ),
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

class FriendItem extends StatefulWidget {
  FriendItem(this.info, this.onItemSelect, this.selectList);
  final V2TimFriendInfo info;
  final Function onItemSelect;
  final List<String> selectList;
  @override
  State<StatefulWidget> createState() => FriendItemState();
}

class FriendItemState extends State<FriendItem> {
  getUserShowName() {
    return widget.info.friendRemark == null || widget.info.friendRemark == ''
        ? widget.info.userID
        : widget.info.friendRemark;
  }

  getUserFaceUrl() {
    return widget.info.userProfile!.faceUrl == null ||
            widget.info.userProfile!.faceUrl == ''
        ? 'images/person.png'
        : widget.info.userProfile!.faceUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        color: CommonColors.getWitheColor(),
        key: Key(widget.info.userID),
        child: InkWell(
          onTap: () {
            setState(() {
              // String checkValue = widget.selectList.contains(widget.info.userID)
              //     ? widget.info.userID
              //     : null;
              widget.onItemSelect(widget.info.userID);
            });
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: CommonColors.getBorderColor(),
                  style: BorderStyle.solid,
                ),
              ),
            ),
            child: Row(
              children: [
                Radio(
                  value: widget.info.userID,
                  groupValue: widget.selectList.contains(widget.info.userID)
                      ? widget.info.userID
                      : null,
                  onChanged: (s) {
                    setState(() {
                      widget.onItemSelect(widget.info.userID);
                    });
                  },
                  toggleable: true,
                ),
                Container(
                  width: 30,
                  height: 30,
                  child: Container(
                    height: 30,
                    width: 30,
                    margin: EdgeInsets.only(
                      right: 4,
                    ),
                    child: Avatar(
                      width: 30,
                      height: 30,
                      radius: 0,
                      avtarUrl: getUserFaceUrl(),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(getUserShowName()),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
