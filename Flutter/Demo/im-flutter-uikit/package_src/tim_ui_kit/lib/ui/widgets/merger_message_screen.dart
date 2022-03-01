import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/main.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';

import '../../i18n/i18n_utils.dart';

class MergerMessageScreen extends StatelessWidget {
  final List<V2TimMessage> messageList;

  const MergerMessageScreen({Key? key, required this.messageList})
      : super(key: key);

  Widget _getMsgItem(V2TimMessage message, I18nUtils ttBuild) {
    final type = message.elemType;
    final isFromSelf = message.isSelf ?? false;

    switch (type) {
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        return Text(ttBuild.imt("[自定义]"));
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return TIMUIKitSoundElem(
            soundElem: message.soundElem!,
            msgID: message.msgID ?? "",
            isFromSelf: isFromSelf);
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return Text(
          message.textElem!.text!,
          softWrap: true,
          style: const TextStyle(fontSize: 16),
        );
      // return Text(message.textElem!.text!);
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        return Text(ttBuild.imt("[表情]"));
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        return TIMUIKitFileElem(fileElem: message.fileElem, isSelf: isFromSelf);
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return TIMUIKitImageElem(message: message);
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return TIMUIKitVideoElem(message);
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        return Text(ttBuild.imt("[位置]"));
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        return TIMUIKitMergerElem(
            mergerElem: message.mergerElem!,
            isSelf: isFromSelf,
            messageID: message.msgID!);
      default:
        return Text(ttBuild.imt("未知消息"));
    }
  }

  double getMaxWidth(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return width - 150;
  }

  Widget _itemBuilder(V2TimMessage message, BuildContext context) {
    final faceUrl = message.faceUrl ?? "";
    final showName = message.nickName ?? message.userID ?? "";
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    final I18nUtils ttBuild = I18nUtils(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Avatar(faceUrl: faceUrl, showName: showName),
          ),
          const SizedBox(
            width: 12,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(showName,
                  style: TextStyle(fontSize: 12, color: theme.weakTextColor)),
              const SizedBox(
                height: 4,
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: getMaxWidth(context)),
                child: _getMsgItem(message, ttBuild),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(
            builder: (context, value, child) => Scaffold(
                  appBar: AppBar(
                      title: Text(
                        ttBuild.imt("聊天记录"),
                        style: TextStyle(color: Colors.black),
                      ),
                      shadowColor: Colors.white,
                      backgroundColor: value.theme.lightPrimaryColor,
                      iconTheme: const IconThemeData(
                        color: Colors.black,
                      )),
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.builder(
                      itemCount: messageList.length,
                      itemBuilder: (context, index) {
                        final messageItem = messageList[index];
                        return _itemBuilder(messageItem, context);
                      },
                    ),
                  ),
                )));
  }
}
