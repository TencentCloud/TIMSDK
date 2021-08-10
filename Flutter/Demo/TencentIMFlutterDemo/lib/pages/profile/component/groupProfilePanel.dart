import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin_example/common/avatar.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:tencent_im_sdk_plugin_example/utils/toast.dart';

class GroupProfilePanel extends StatelessWidget {
  GroupProfilePanel(this.userInfo);
  final V2TimGroupInfoResult? userInfo;
  getGroupName() {
    return userInfo!.groupInfo!.groupName == null ||
            userInfo!.groupInfo!.groupName == ''
        ? userInfo!.groupInfo!.groupID
        : userInfo!.groupInfo!.groupName;
  }

  @override
  Widget build(BuildContext context) {
    if (userInfo == null) {
      return Container(
        height: 112,
      );
    }

    return Material(
      child: Ink(
        color: CommonColors.getWitheColor(),
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min, // 设置最小的弹出
                    children: <Widget>[
                      new ListTile(
                        title: new Text(
                          "修改群名称",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: CommonColors.getThemeColor()),
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertName(userInfo!.groupInfo!.groupID);
                              });
                        },
                      ),
                      new ListTile(
                        title: new Text(
                          "修改群简介",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: CommonColors.getThemeColor()),
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertIntro(userInfo!.groupInfo!.groupID);
                              });
                        },
                      ),
                    ],
                  );
                });
          },
          child: Container(
            height: 112,
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  child: Avatar(
                    avtarUrl: userInfo!.groupInfo!.faceUrl == null ||
                            userInfo!.groupInfo!.faceUrl == ''
                        ? 'images/logo.png'
                        : userInfo!.groupInfo!.faceUrl,
                    width: 80,
                    height: 80,
                    radius: 9.6,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 昵称
                        Container(
                          height: 34,
                          child: Text(
                            getGroupName(),
                            style: TextStyle(
                              fontSize: 24,
                              color: CommonColors.getTextBasicColor(),
                            ),
                          ),
                        ),
                        Container(
                          height: 23,
                          child: Text(
                            '群ID：${userInfo!.groupInfo!.groupID}',
                            style: TextStyle(
                              fontSize: 14,
                              color: CommonColors.getTextWeakColor(),
                            ),
                          ),
                        ),
                        Container(
                          height: 23,
                          child: Text(
                            '群简介：${userInfo!.groupInfo!.introduction}',
                            style: TextStyle(
                              fontSize: 14,
                              color: CommonColors.getTextWeakColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_right_outlined)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AlertName extends StatefulWidget {
  AlertName(this.groupId);
  final String groupId;
  @override
  State<StatefulWidget> createState() => AlertDialogState();
}

class AlertIntro extends StatefulWidget {
  AlertIntro(this.groupId);
  final String groupId;
  @override
  State<StatefulWidget> createState() => AlertDialogAlertIntroState();
}

class AlertDialogAlertIntroState extends State<AlertIntro> {
  String? name;
  TextEditingController controller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text('修改群简介'),
      content: TextField(
        controller: controller,
        onChanged: (s) {
          setState(() {
            name = s;
          });
        },
      ),
      actions: <Widget>[
        new ElevatedButton(
          child: new Text('取消'),
          onPressed: () {
            Navigator.of(context).pop();
            print('取消');
          },
        ),
        new ElevatedButton(
          child: new Text('确定'),
          onPressed: () {
            TencentImSDKPlugin.v2TIMManager
                .getGroupManager()
                .setGroupInfo(
                  info: V2TimGroupInfo.fromJson(
                    {
                      "introduction": name,
                      "groupID": widget.groupId,
                    },
                  ),
                )
                .then((value) {
              if (value.code == 0) {
                Navigator.of(context).pop();
                Utils.toast('修改成功');
                Navigator.of(context).pop();
              }
            });
          },
        )
      ],
    );
  }
}

class AlertDialogState extends State<AlertName> {
  String? name;
  TextEditingController controller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text('修改群名称'),
      content: TextField(
        controller: controller,
        onChanged: (s) {
          setState(() {
            name = s;
          });
        },
      ),
      actions: <Widget>[
        new ElevatedButton(
          child: new Text('取消'),
          onPressed: () {
            Navigator.of(context).pop();
            print('取消');
          },
        ),
        new ElevatedButton(
          child: new Text('确定'),
          onPressed: () {
            TencentImSDKPlugin.v2TIMManager
                .getGroupManager()
                .setGroupInfo(
                    info: V2TimGroupInfo.fromJson({
                  "groupName": name,
                  "groupID": widget.groupId,
                }))
                .then((value) {
              if (value.code == 0) {
                Navigator.of(context).pop();
                Utils.toast('修改成功');
                Navigator.of(context).pop();
              }
            });
            print('确定');
          },
        )
      ],
    );
  }
}
