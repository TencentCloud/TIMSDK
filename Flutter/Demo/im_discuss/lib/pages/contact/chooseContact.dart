import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tencent_im_sdk_plugin/enum/group_type.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:discuss/common/avatar.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/pages/conversion/conversion.dart';
import 'package:discuss/provider/multiselect.dart';
import 'package:discuss/utils/toast.dart';

class ChooseContact extends StatefulWidget {
  const ChooseContact(this.type, this.groupID, {Key? key}) : super(key: key);
  final int type; //1 个人，2群组 3,讨论组 4、聊天室
  final dynamic groupID;
  // 2、3、4均支持多选
  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => ChooseContactState(type, groupID);
}

class ShareDataWidget extends InheritedWidget {
  const ShareDataWidget(
      {Key? key, required this.checkList, required Widget child})
      : super(key: key, child: child);
  final List<String> checkList;
  static ShareDataWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShareDataWidget>();
  }

  @override
  // ignore: avoid_renaming_method_parameters
  bool updateShouldNotify(covariant ShareDataWidget old) {
    return old.checkList != checkList;
  }
}

class ChooseContactState extends State<ChooseContact> {
  List<V2TimFriendInfo> list = [];

  Map<String, String> selectMap = <String, String>{};
  List<String> selectList = List.empty(growable: true);
  late int type;
  late dynamic groupID;
  late List<String> msgIds;
  ChooseContactState(this.type, groupID) {
    if (groupID.runtimeType == String) {
      this.groupID = groupID;
    } else {
      if (groupID.runtimeType.toString() == 'List<String>') {
        msgIds = groupID;
      }
    }
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
      setState(() {
        selectList = newList;
      });
    });
  }

  String disPlayLastMessage(V2TimMessage message) {
    String res = "";

    int elemType = message.elemType;
    switch (elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        res = "【自定义消息】";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        res = "【表情】";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        res = "【文件】";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        res = "【群提示】";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        res = "【图片】";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        res = "【位置】";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        res = "【合并消息】";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_NONE:
        res = "【NONE】";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        res = "【语音】";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        res = message.textElem!.text!;
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        res = "【视频】";
        break;
    }
    return res;
  }

  getFriendList() async {
    V2TimValueCallback<List<V2TimFriendInfo>> data = await TencentImSDKPlugin
        .v2TIMManager
        .getFriendshipManager()
        .getFriendList();
    if (data.code == 0) {
      setState(() {
        list = data.data!;
      });
    }
  }

  String getMergeMessageTitle(List<V2TimMessage> messages) {
    String res = "转发消息";
    if (messages.isNotEmpty) {
      res =
          "${messages[0].sender}与${messages[0].nickName ?? messages[0].userID}的聊天记录";
    }
    return res;
  }

  List<String> getMergeMessageAbstractList(List<V2TimMessage> messages) {
    List<String> res = [];
    for (V2TimMessage element in messages) {
      res.add("${element.sender}：${disPlayLastMessage(element)}");
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        shadowColor: hexToColor("ececec"),
        elevation: 1,
        title: const Text(
          "选择联系人",
          style: TextStyle(color: Colors.black),
        ),
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
                      const Expanded(
                        child: Text(''),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ElevatedButton(
                          child: const Text("确定"),
                          onPressed: selectList.isEmpty
                              ? null
                              : () async {
                                  // 如果是单聊，直接打开会话，如果是群聊，需要先创建群
                                  if (type == 1) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
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
                                      case 7:
                                        if (msgIds.isNotEmpty) {
                                          V2TimValueCallback<List<V2TimMessage>>
                                              res = await TencentImSDKPlugin
                                                  .v2TIMManager
                                                  .getMessageManager()
                                                  .findMessages(
                                                    messageIDList: msgIds,
                                                  );
                                          if (res.code == 0) {
                                            List<V2TimMessage> messages =
                                                res.data!;
                                            V2TimValueCallback<
                                                    V2TimMsgCreateInfoResult>
                                                createResult = await TencentImSDKPlugin
                                                    .v2TIMManager
                                                    .getMessageManager()
                                                    .createMergerMessage(
                                                        msgIDList: msgIds,
                                                        title:
                                                            getMergeMessageTitle(
                                                                messages),
                                                        abstractList:
                                                            getMergeMessageAbstractList(
                                                                messages),
                                                        compatibleText:
                                                            "该版本不支持此消息");
                                            String id = createResult
                                                .toJson()["data"]["id"];
                                            await TencentImSDKPlugin
                                                .v2TIMManager
                                                .getMessageManager()
                                                .sendMessage(
                                                  id: id,
                                                  receiver: selectList[0],
                                                  groupID: "",
                                                );
                                            Provider.of<MultiSelect>(context,
                                                    listen: false)
                                                .exit();
                                            Navigator.pop(context);
                                          }
                                        }
                                        return;
                                    }
                                    List<Map> newlist =
                                        List.empty(growable: true);
                                    for (var element in selectList) {
                                      Map user = {};
                                      user['userID'] = element;
                                      user['role'] = 200;
                                      newlist.add(user);
                                    }
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
                                          MaterialPageRoute(
                                            builder: (context) => Conversion(
                                              "group_$groupId",
                                            ),
                                          ),
                                        );
                                      } else {
                                        Utils.toast("${res.code} ${res.desc}");
                                      }
                                    } else {
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
  const FriendItem(this.info, this.onItemSelect, this.selectList, {Key? key})
      : super(key: key);
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
                SizedBox(
                  width: 30,
                  height: 30,
                  child: Container(
                    height: 30,
                    width: 30,
                    margin: const EdgeInsets.only(
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
                  padding: const EdgeInsets.only(left: 10),
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
