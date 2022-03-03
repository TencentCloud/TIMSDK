import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/main.dart';

import '../../../../i18n/i18n_utils.dart';
import '../tim_uikit_chat.dart';

class CloudCustomData {
  late Map<String, dynamic> messageReply;
  late String messageAbstract;
  late String messageSender;
  late String messageID;

  CloudCustomData.fromJson(json) {
    messageReply = json["messageReply"];
    messageAbstract = messageReply["messageAbstract"];
    messageSender = messageReply["messageSender"];
    messageID = messageReply["messageID"];
  }
}

class TIMUIKitReplyElem extends StatefulWidget {
  final V2TimMessage message;
  const TIMUIKitReplyElem({Key? key, required this.message}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitReplyElemState();
}

class _TIMUIKitReplyElemState extends State<TIMUIKitReplyElem> {
  TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  CloudCustomData? reqpliedMessage;
  V2TimMessage? rawMessage;

  CloudCustomData? _getRepliedMessage() {
    try {
      final messageCloudCustomData =
          json.decode(widget.message.cloudCustomData!);
      final repliedMessage = CloudCustomData.fromJson(messageCloudCustomData);
      return repliedMessage;
    } catch (error) {
      return null;
    }
  }

  _getMessageByMessageID() async {
    final cloudCustomData = _getRepliedMessage();
    if (cloudCustomData != null) {
      final messageID = cloudCustomData.messageID;
      final message = await model.findMessage(messageID);
      if (message != null) {
        setState(() {
          rawMessage = message;
        });
      }
    }
    setState(() {
      reqpliedMessage = cloudCustomData;
    });
  }

  _rawMessageBuilder(V2TimMessage? message, TUITheme? theme) {
    if (message == null) {
      return Text(
        reqpliedMessage!.messageAbstract,
        style: TextStyle(
            fontSize: 12,
            color: theme?.weakTextColor,
            fontWeight: FontWeight.w400),
      );
    }
    final messageType = message.elemType;
    final isSelf = message.isSelf ?? false;
    final I18nUtils ttBuild = I18nUtils(context);
    switch (messageType) {
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        return Text(ttBuild.imt("[自定义]"));
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return Text(ttBuild.imt("[语音消息]"));
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return Text(
          message.textElem?.text ?? "",
          style: TextStyle(
              fontSize: 12,
              color: theme?.weakTextColor,
              fontWeight: FontWeight.w400),
        );
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        return Text(ttBuild.imt("[表情]"));
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        return TIMUIKitFileElem(fileElem: message.fileElem, isSelf: isSelf);
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return TIMUIKitImageElem(
          message: message,
        );
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return TIMUIKitVideoElem(message);
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        return Text(ttBuild.imt("[位置]"));
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        return TIMUIKitMergerElem(
            mergerElem: message.mergerElem!,
            messageID: message.msgID ?? "",
            isSelf: isSelf);
      default:
        return Text(ttBuild.imt("[未知消息]"));
    }
  }

  @override
  void initState() {
    _getMessageByMessageID();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TIMUIKitReplyElem oldWidget) {
    _getMessageByMessageID();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SharedThemeWidget.of(context)?.theme;
    if (reqpliedMessage == null) {
      return Container();
    }
    final isFromSelf = widget.message.isSelf ?? false;

    final borderRadius = isFromSelf
        ? const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(2),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10))
        : const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10));
    final backgroundColor = isFromSelf
        ? const Color.fromRGBO(220, 234, 253, 1)
        : const Color.fromRGBO(236, 236, 236, 1);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      constraints: const BoxConstraints(maxWidth: 240),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // 这里是引用的部分
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            constraints: const BoxConstraints(minWidth: 120),
            decoration: const BoxDecoration(
                color: Color.fromRGBO(68, 68, 68, 0.05),
                border: Border(
                    left: BorderSide(
                        color: Color.fromRGBO(68, 68, 68, 0.1), width: 2))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${reqpliedMessage!.messageSender}:",
                  style: TextStyle(
                      fontSize: 12,
                      color: theme?.weakTextColor,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 4,
                ),
                _rawMessageBuilder(rawMessage, theme)
              ],
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            widget.message.textElem?.text ?? "",
            softWrap: true,
            style: const TextStyle(
              fontSize: 16,
            ),
          )
        ],
      ),
    );
  }
}
