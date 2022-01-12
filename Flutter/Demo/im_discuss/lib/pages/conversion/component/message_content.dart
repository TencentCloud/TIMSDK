import 'package:discuss/common/colors.dart';
import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/pages/conversion/component/common_content.dart';
import 'package:discuss/provider/historymessagelistprovider.dart';
import 'package:discuss/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/enum/message_status.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class MessageContent extends StatefulWidget {
  final V2TimMessage message;
  final String selectedMsgId;
  final void Function(String msgId) setSelectedMsgId;
  const MessageContent(
      {Key? key,
      required this.message,
      required this.selectedMsgId,
      required this.setSelectedMsgId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => MessageContentState();
}

class MessageContentState extends State<MessageContent> {
  bool isC2CMessage() {
    return widget.message.userID != null;
  }

  bool isSelf() {
    return widget.message.isSelf!;
  }

  getShowName() {
    return widget.message.friendRemark == null ||
            widget.message.friendRemark == ''
        ? widget.message.nickName == null || widget.message.nickName == ''
            ? widget.message.sender
            : widget.message.nickName
        : widget.message.friendRemark;
  }

  showNickName() {
    if (!isC2CMessage()) {
      // group 消息
      if (!isSelf()) {
        //非自己
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 10,
              ),
              child: Text(
                getShowName(),
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 12,
                  color: CommonColors.getTextWeakColor(),
                ),
              ),
            )
          ],
        );
      }
    }
    return Container();
  }

  String? msgId;
  @override
  initState() {
    setState(() {
      msgId = widget.message.msgID;
    });
    super.initState();
  }

  reSendmesasge() async {
    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .reSendMessage(msgID: msgId!);
    String key = (widget.message.userID != null
        ? "c2c_${widget.message.userID}"
        : "group_${widget.message.groupID}");
    if (res.code == 0) {
      Provider.of<HistoryMessageListProvider>(context, listen: false)
          .updateMessage(key, msgId!, res.data!);
    } else {
      // 重发失败要更新消息，因为失败的消息id没有了

      try {
        Provider.of<HistoryMessageListProvider>(context, listen: false)
            .updateMessage(key, msgId!, res.data!);
      } catch (err) {
        Utils.log("$err");
      }
      setState(() {
        msgId = res.data!.msgID;
      });
      Utils.toast(res.desc);
    }
  }

  // 消息发送失败时显示的内容区
  Widget getHandleBar() {
    Widget wid = Container();
    V2TimMessage message = widget.message;
    int elemType = message.elemType;
    List notShowType = [
      MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS,
      MessageElemType.V2TIM_ELEM_TYPE_NONE,
    ];
    if (notShowType.contains(elemType)) {
      return wid;
    }
    if (message.isSelf != null && message.isSelf!) {
      if (message.status == MessageStatus.V2TIM_MSG_STATUS_SEND_SUCC &&
          message.userID != null) {
        if (message.isPeerRead == true) {
          //c2c消息已读
          wid = Text(
            "已读",
            style: TextStyle(
              fontSize: 10,
              color: hexToColor("B2B2B2"),
            ),
          );
        }
        if (message.isPeerRead == false) {
          //c2c未读
          wid = Text(
            "未读",
            style: TextStyle(
              fontSize: 10,
              color: hexToColor("B2B2B2"),
            ),
          );
        }
      }
      if (message.status == MessageStatus.V2TIM_MSG_STATUS_SEND_FAIL) {
        wid = Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_outlined,
              size: 12,
              color: CommonColors.getReadColor(),
            ),
            Text(
              "发送失败",
              style: TextStyle(
                fontSize: 10,
                color: CommonColors.getReadColor(),
                height: 1.4,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 5),
              child: InkWell(
                onTap: reSendmesasge,
                child: const Text(
                  "重新发送",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue,
                    height: 1.4,
                  ),
                ),
              ),
            )
          ],
        );
      }
      if (message.status == MessageStatus.V2TIM_MSG_STATUS_SENDING) {
        wid = Text(
          "发送中...",
          style: TextStyle(
            fontSize: 10,
            color: hexToColor("B2B2B2"),
          ),
        );
      }
    }
    // 非自己消息不作处理
    return wid;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        showNickName(),
        Row(
          mainAxisAlignment:
              isSelf() ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            CommonMessageContent(
                message: widget.message,
                selectedMsgId: widget.selectedMsgId,
                setSelectedMsgId: widget.setSelectedMsgId),
          ],
        ),
        // 消息发送失败时显示的内容区
        Container(
          padding: const EdgeInsets.only(right: 10),
          child: getHandleBar(),
        )
      ],
    );
  }
}
