import 'package:discuss/common/avatar.dart';
import 'package:discuss/pages/conversion/component/fixposition.dart';
import 'package:discuss/pages/conversion/component/message_content.dart';
import 'package:discuss/provider/multiselect.dart';
import 'package:discuss/utils/commonUtils.dart';
import 'package:discuss/utils/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'dart:convert' as convert;

class DisplayTextMessage extends StatefulWidget {
  final V2TimMessage mesage;
  final String selectedMsgId;
  final void Function(String msgId) setSelectedMsgId;

  const DisplayTextMessage(
      {Key? key,
      required this.mesage,
      required this.selectedMsgId,
      required this.setSelectedMsgId})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => DisplayTextMessageState();
}

class DisplayTextMessageState extends State<DisplayTextMessage> {
  // 确认自己是否是消息发送方
  bool isSelf() {
    V2TimMessage message = widget.mesage;
    return message.isSelf!;
  }

  bool isTime() {
    return widget.mesage.elemType == Const.V2TIM_ELEM_TYPE_TIME;
  }

  Widget showCheckBox(context) {
    V2TimMessage message = widget.mesage;
    // 文本消息，自定义消息，多媒体消息支持多选
    List<int> validateType = [
      MessageElemType.V2TIM_ELEM_TYPE_CUSTOM,
      MessageElemType.V2TIM_ELEM_TYPE_FILE,
      MessageElemType.V2TIM_ELEM_TYPE_IMAGE,
      MessageElemType.V2TIM_ELEM_TYPE_SOUND,
      MessageElemType.V2TIM_ELEM_TYPE_TEXT,
      MessageElemType.V2TIM_ELEM_TYPE_VIDEO
    ];
    if (message.msgID == null) {
      return Container();
    }
    late String selectorId;
    if (message.groupID != null) {
      selectorId = message.groupID!;
    } else {
      selectorId = message.userID!;
    }
    String messageId = message.msgID!;
    bool isopen = Provider.of<MultiSelect>(context, listen: true).isopen;

    bool isCheck = false;
    List<String>? selectList =
        Provider.of<MultiSelect>(context, listen: true).selectedIds[selectorId];
    if (selectList != null) {
      if (selectList.contains(messageId)) {
        isCheck = true;
      }
    }
    if (validateType.contains(message.elemType)) {
      if (isopen) {
        return Checkbox(
            value: isCheck,
            onChanged: (check) {
              Provider.of<MultiSelect>(context, listen: false)
                  .updateSeletor(selectorId, message.msgID!);
            });
      }
    }
    return Container();
  }

  showAvatar() {
    V2TimMessage message = widget.mesage;

    return Avatar(
      avtarUrl: message.faceUrl ?? 'images/logo.png',
      width: CommonUtils.adaptWidth(80),
      height: CommonUtils.adaptHeight(80),
      radius: 4.8,
    );
  }

  // 判断是否是话题消息
  bool isTopicInfo() {
    V2TimMessage message = widget.mesage;
    if (message.customElem != null) {
      var customElem = message.customElem?.data;
      var decodedMap = convert.jsonDecode(customElem!);
      String? type = decodedMap['type'] ?? "";

      return type == "discuss";
    }
    return false;
  }

  bool isShowOtherCheckBox() {
    return !isSelf() && !isTopicInfo();
  }

  @override
  Widget build(BuildContext context) {
    V2TimMessage message = widget.mesage;
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        textDirection: isSelf() ? TextDirection.rtl : TextDirection.ltr,
        mainAxisAlignment:
            isSelf() ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 他人消息出现的checkBox
          isShowOtherCheckBox() ? showCheckBox(context) : Container(),
          !isTime() ? showAvatar() : const FixPosition(),
          Expanded(
            child: GestureDetector(
              onTap: () {
                bool isopen =
                    Provider.of<MultiSelect>(context, listen: false).isopen;
                if (isopen) {
                  V2TimMessage message = widget.mesage;
                  late String selectorId;
                  if (message.groupID != null) {
                    selectorId = message.groupID!;
                  } else {
                    selectorId = message.userID!;
                  }

                  Provider.of<MultiSelect>(context, listen: false)
                      .updateSeletor(selectorId, message.msgID!);
                }
              },
              child: MessageContent(
                  message: message,
                  selectedMsgId: widget.selectedMsgId,
                  setSelectedMsgId: widget.setSelectedMsgId),
            ),
          ),
          // 自己消息出现的checkBox
          const FixPosition(),
          isSelf() ? showCheckBox(context) : Container(),
        ],
      ),
    );
  }
}
