import 'package:discuss/utils/commonUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:discuss/common/avatar.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/utils/toast.dart';

//自己查看自己的资料
class ProfilePanel extends StatelessWidget {
  const ProfilePanel(this.userInfo, this.isSelf, {Key? key}) : super(key: key);
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
            List profileActionList = [
              {
                'name': '修改昵称',
              },
            ];

            showCupertinoModalPopup<String>(
              context: context,
              builder: (BuildContext context) {
                return CupertinoActionSheet(
                  title: null,
                  actions: profileActionList
                      .map(
                        (e) => CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.of(context).pop();
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return const Alert();
                                });
                          },
                          child: Text(e['name']),
                          isDefaultAction: false,
                        ),
                      )
                      .toList(),
                );
              },
            );
          },
          child: Container(
            height: CommonUtils.adaptHeight(200),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Avatar(
                    avtarUrl:
                        userInfo!.faceUrl == null || userInfo!.faceUrl == ''
                            ? 'images/logo.png'
                            : userInfo!.faceUrl,
                    width: CommonUtils.adaptWidth(96),
                    height: CommonUtils.adaptHeight(96),
                    radius: 9.6,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: CommonUtils.adaptHeight(188),
                    margin: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 昵称
                        SizedBox(
                          height: CommonUtils.adaptHeight(48),
                          child: Text(
                            (userInfo!.nickName == null ||
                                    userInfo!.nickName == '')
                                ? "${userInfo!.userID}"
                                : "${userInfo!.nickName}",
                            style: TextStyle(
                              fontSize: CommonUtils.adaptFontSize(36),
                              color: CommonColors.getTextBasicColor(),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          height: CommonUtils.adaptHeight(40),
                          child: Text(
                            '用户ID：${userInfo!.userID}',
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(26),
                              color: CommonColors.getTextWeakColor(),
                            ),
                          ),
                        ),
                        !isSelf
                            ? SizedBox(
                                height: CommonUtils.adaptHeight(40),
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
                const Icon(Icons.keyboard_arrow_right_outlined)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Alert extends StatefulWidget {
  const Alert({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AlertDialogState();
}

class AlertDialogState extends State<Alert> {
  String? name;
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('修改昵称'),
      content: TextField(
        controller: controller,
        onChanged: (s) {
          setState(() {
            name = s;
          });
        },
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('取消'),
          onPressed: () {
            Navigator.of(context).pop();
            Utils.log('取消');
          },
        ),
        ElevatedButton(
          child: const Text('确定'),
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
            Utils.log('确定');
          },
        )
      ],
    );
  }
}
