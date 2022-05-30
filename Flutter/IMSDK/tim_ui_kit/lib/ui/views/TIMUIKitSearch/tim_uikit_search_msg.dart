// ignore_for_file: must_be_immutable, unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_search_result_item.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_search_view_model.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/pureUI/tim_uikit_search_item.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/pureUI/tim_uikit_search_folder.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/tim_uikit_search_msg_detail.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/pureUI/tim_uikit_search_showAll.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

class TIMUIKitSearchMsg extends StatelessWidget {
  List<V2TimMessageSearchResultItem?> msgList;
  int totalMsgCount;
  String keyword;
  final Function(V2TimConversation, V2TimMessage?) onTapConversation;
  final model = serviceLocator<TUISearchViewModel>();
  final Function(V2TimConversation, String) onEnterConversation;

  TIMUIKitSearchMsg(
      {required this.msgList,
      required this.keyword,
      required this.totalMsgCount,
      Key? key,
      required this.onTapConversation,
      required this.onEnterConversation})
      : super(key: key);

  Widget _renderShowALl(bool isShowMore, I18nUtils ttBuild) {
    return (isShowMore == true)
        ? TIMUIKitSearchShowALl(
            textShow: ttBuild.imt("更多聊天记录"),
            onClick: () => {model.searchMsgByKey(keyword, false)},
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    List<V2TimConversation?> _conversationList =
        Provider.of<TUISearchViewModel>(context).conversationList;

    if (msgList.isNotEmpty) {
      return TIMUIKitSearchFolder(folderName: ttBuild.imt("聊天记录"), children: [
        ...msgList.map((conv) {
          V2TimConversation conversation = _conversationList[
              _conversationList.indexWhere(
                  (item) => item!.conversationID == conv?.conversationID)]!;
          final option1 = conv?.messageCount;
          return TIMUIKitSearchItem(
            onClick: () async {
              onEnterConversation(conversation, keyword);
            },
            faceUrl: conversation.faceUrl ?? "",
            showName: conversation.showName ?? "",
            lineOne: conversation.showName ?? "",
            lineTwo: ttBuild.imt_para("{{option1}}条相关聊天记录", "$option1条相关聊天记录")(
                option1: option1),
          );
        }).toList(),
        _renderShowALl(totalMsgCount > msgList.length, ttBuild)
      ]);
    } else {
      return Container();
    }
  }
}
