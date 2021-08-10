import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin_example/common/avatar.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:tencent_im_sdk_plugin_example/utils/toast.dart';

//自己查看自己的资料
class ProfilePanel extends StatelessWidget {
  ProfilePanel(this.userInfo, this.isSelf);
  final V2TimUserFullInfo? userInfo;
  final bool isSelf;
  getSelfSignature() {
    if (userInfo!.selfSignature == '' || userInfo!.selfSignature == null) {
      return "";
    } else {
      return userInfo!.selfSignature;
    }
  }

  hasNickName() {
    return !(userInfo!.nickName == '' || userInfo!.nickName == null);
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
                          "修改昵称",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: CommonColors.getThemeColor()),
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Alert();
                              });
                        },
                      )
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
                    avtarUrl:
                        userInfo!.faceUrl == null || userInfo!.faceUrl == ''
                            ? 'images/logo.png'
                            : userInfo!.faceUrl,
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
                            (userInfo!.nickName == null ||
                                    userInfo!.nickName == '')
                                ? "${userInfo!.userID}"
                                : "${userInfo!.nickName}",
                            style: TextStyle(
                              fontSize: 24,
                              color: CommonColors.getTextBasicColor(),
                            ),
                          ),
                        ),
                        Container(
                          height: 23,
                          child: Text(
                            '用户ID：${userInfo!.userID}',
                            style: TextStyle(
                              fontSize: 14,
                              color: CommonColors.getTextWeakColor(),
                            ),
                          ),
                        ),
                        !isSelf
                            ? Container(
                                height: 23,
                                child: Text(
                                  '个性签名：${getSelfSignature()}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: CommonColors.getTextWeakColor(),
                                  ),
                                ),
                              )
                            : Container(),
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

class Alert extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AlertDialogState();
}

class AlertDialogState extends State<Alert> {
  String? name;
  TextEditingController controller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text('修改昵称'),
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
                .setSelfInfo(
              userFullInfo: V2TimUserFullInfo.fromJson(
                {
                  "nickName": name,
                },
              ),
            )
                .then((value) {
              if (value.code == 0) {
                Navigator.of(context).pop();
                Utils.toast('修改成功');
              }
            });
            print('确定');
          },
        )
      ],
    );
  }
}
