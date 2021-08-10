import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin_example/common/avatar.dart';
import 'package:tencent_im_sdk_plugin_example/pages/conversion/component/MsgBody.dart';
import 'package:tencent_im_sdk_plugin_example/pages/conversion/component/fixPosition.dart';

class SendMsg extends StatelessWidget {
  SendMsg(this.message, this.key);
  final V2TimMessage message;
  final Key key;
  getShowMessage() {
    String msg = '';
    print("message:$message");
    switch (message.elemType) {
      case 1:
        msg = message.textElem?.text ?? "";
        break;
      case 2:
        msg = message.customElem?.data ?? "";
        break;
      case 3:
        msg = message.imageElem?.path ?? "";
        break;
      case 4:
        msg = message.soundElem?.path ?? "";
        break;
      case 5:
        msg = message.videoElem?.videoPath ?? "";
        break;
      case 6:
        msg = message.fileElem?.fileName ?? "";
        break;
      case 7:
        msg = message.locationElem?.desc ?? "";
        break;
      case 8:
        msg = message.faceElem?.data ?? "";
        break;
      case 9:
        msg = "系统消息";
        break;
    }

    return msg;
  }

  getShowName() {
    return message.friendRemark == null || message.friendRemark == ''
        ? message.nickName == null || message.nickName == ''
            ? message.sender
            : message.nickName
        : message.friendRemark;
  }

  @override
  Widget build(BuildContext context) {
    if (message.msgID == null || message.msgID == '') {
      return Container();
    }
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        textDirection: message.isSelf! ? TextDirection.rtl : TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (!message.isSelf!) {
                print("1111");
                // 区分群内消息和普通好友消息
              }
            },
            child: Avatar(
              avtarUrl: message.faceUrl == null || message.faceUrl == ''
                  ? 'images/logo.png'
                  : message.faceUrl,
              width: 40,
              height: 40,
              radius: 4.8,
            ),
          ),
          MsgBody(
            type: message.isSelf! ? 1 : 2,
            name: getShowName(),
            messageText: getShowMessage(),
            message: message,
          ),
          FixPosition()
        ],
      ),
    );
  }
}
