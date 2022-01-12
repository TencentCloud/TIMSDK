import 'package:discuss/pages/conversion/component/display_text_message.dart';
import 'package:discuss/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:discuss/provider/multiselect.dart';
import 'package:discuss/utils/const.dart';

class SendMsg extends StatefulWidget {
  final V2TimMessage message;
  final String selectedMsgId;
  final void Function(String msgId) setSelectedMsgId;
  const SendMsg(
      {Key? key,
      required this.message,
      required this.selectedMsgId,
      required this.setSelectedMsgId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => SendMsgState();
}

class SendMsgState extends State<SendMsg> {
  getShowMessage() {
    V2TimMessage message = widget.message;
    String msg = '';
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

  Widget showCheckBox(context) {
    V2TimMessage message = widget.message;
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

  Widget handleDiffMessage() {
    V2TimMessage message = widget.message;
    Widget messageWidget = Container();
    if (message.msgID!.isNotEmpty) {
      int type = message.elemType;
      switch (type) {
        case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        case Const.V2TIM_ELEM_TYPE_TIME:
          messageWidget = DisplayTextMessage(
              mesage: message,
              selectedMsgId: widget.selectedMsgId,
              setSelectedMsgId: widget.setSelectedMsgId);
          break;
      }
    }
    return messageWidget;
  }

  @override
  Widget build(BuildContext context) {
    V2TimMessage message = widget.message;

    if (message.msgID == null || message.msgID == '') {
      Utils.log("存在没有msgID的消息 ${message.toJson()}");
      return Container();
    }
    return handleDiffMessage();
  }
}
