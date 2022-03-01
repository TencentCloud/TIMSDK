import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/enum/message_status.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_at_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';

import '../../../i18n/i18n_utils.dart';

class TIMUIKitLastMsg extends StatelessWidget {
  final V2TimMessage? lastMsg;
  final List<V2TimGroupAtInfo?> groupAtInfoList;
  final BuildContext context;
  const TIMUIKitLastMsg({Key? key, this.lastMsg, required this.groupAtInfoList, required this.context})
      : super(key: key);

  String _getMsgElem() {
    final I18nUtils ttBuild = I18nUtils(context);
    final msgType = lastMsg!.elemType;
    final isRevokedMessage = lastMsg!.status == 6;
    if (isRevokedMessage) {
      final isSelf = lastMsg!.isSelf ?? false;
      final displayName = isSelf ? ttBuild.imt("您") : lastMsg!.nickName ?? lastMsg?.sender;
      return ttBuild.imt_para("{{displayName}}撤回了一条消息", "${displayName}撤回了一条消息")(displayName: displayName);
    }
    switch (msgType) {
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        return ttBuild.imt("[自定义]");
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return ttBuild.imt("[语音]");
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return lastMsg!.textElem!.text as String;
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        return ttBuild.imt("[表情]");
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        final fileName = lastMsg!.fileElem!.fileName;
        return ttBuild.imt_para("[文件] {{fileName}}", "[文件] ${fileName}")(fileName: fileName);
      case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        return MessageUtils.groupTipsMessageAbstract(lastMsg!.groupTipsElem!, context);
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return ttBuild.imt("[图片]");
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return ttBuild.imt("[视频]");
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        return ttBuild.imt("[位置]");
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        return ttBuild.imt("[聊天记录]");
      default:
        return ttBuild.imt("未知消息");
    }
  }

  Icon? _getIconByMsgStatus(BuildContext context) {
    final msgStatus = lastMsg!.status;
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    if (msgStatus == MessageStatus.V2TIM_MSG_STATUS_SEND_FAIL) {
      return Icon(Icons.error, color: theme.cautionColor);
    }
  }

  String _getAtMessage() {
    var messageString = "";
    final I18nUtils ttBuild = I18nUtils(context);
    for (var item in groupAtInfoList) {
      if (item!.atType == 1) {
        messageString = ttBuild.imt_para("{{messageString}}[有人@我]", "${messageString}[有人@我]")(messageString: messageString);
      } else {
        messageString = ttBuild.imt_para("{{messageString}}[@所有人]", "${messageString}[@所有人]")(messageString: messageString);
      }
    }
    return messageString;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(builder: (context, value, child) {
          final icon = _getIconByMsgStatus(context);
          final theme = value.theme;
          return Row(children: [
            if (icon != null) icon,
            if (groupAtInfoList.isNotEmpty)
              Text(_getAtMessage(),
                  style: TextStyle(color: theme.cautionColor)),
            Expanded(
                child: Text(
              _getMsgElem(),
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  height: 1.5, color: theme.weakTextColor, fontSize: 14),
            )),
          ]);
        }));
  }
}
