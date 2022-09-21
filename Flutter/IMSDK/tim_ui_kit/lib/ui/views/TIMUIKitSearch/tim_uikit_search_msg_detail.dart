import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/platform.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/pureUI/tim_uikit_search_input.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/pureUI/tim_uikit_search_item.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_search_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/pureUI/tim_uikit_search_showAll.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/tim_uikit_search_not_support.dart';

class TIMUIKitSearchMsgDetail extends StatefulWidget {
  /// Conversation need search
  final V2TimConversation currentConversation;

  /// initial keyword
  final String keyword;

  /// the callback after clicking each conversation message item
  final Function(V2TimConversation, V2TimMessage?) onTapConversation;

  const TIMUIKitSearchMsgDetail(
      {Key? key,
      required this.currentConversation,
      required this.keyword,
      required this.onTapConversation})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => TIMUIKitSearchMsgDetailState();
}

class TIMUIKitSearchMsgDetailState
    extends TIMUIKitState<TIMUIKitSearchMsgDetail> {
  final model = serviceLocator<TUISearchViewModel>();
  String keywordState = "";
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    keywordState = widget.keyword;
    updateMsgResult(widget.keyword, true);
  }

  String _getMsgElem(V2TimMessage message) {
    final msgType = message.elemType;
    final isRevokedMessage = message.status == 6;
    if (isRevokedMessage) {
      final isSelf = message.isSelf ?? false;
      final option2 = isSelf ? TIM_t("您") : message.nickName ?? message.sender;
      return TIM_t_para("{{option2}}撤回了一条消息", "$option2撤回了一条消息")(
          option2: option2);
    }
    switch (msgType) {
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        return TIM_t("[自定义]");
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return TIM_t("[语音]");
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return message.textElem!.text as String;
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        return TIM_t("[表情]");
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        final option1 = message.fileElem!.fileName;
        return TIM_t_para("[文件] {{option1}}", "[文件] $option1")(
            option1: option1);
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return TIM_t("[图片]");
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return TIM_t("[视频]");
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        return TIM_t("[位置]");
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        return TIM_t("[聊天记录]");
      default:
        return TIM_t("未知消息");
    }
  }

  List<Widget> _renderListMessage(
      List<V2TimMessage> msgList, BuildContext context) {
    List<Widget> listWidget = [];

    listWidget = msgList.map((message) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: TIMUIKitSearchItem(
          faceUrl: message.faceUrl ?? "",
          showName: message.nickName ?? message.userID ?? message.sender ?? "",
          lineOne: message.nickName ?? message.userID ?? message.sender ?? "",
          lineTwo: _getMsgElem(message),
          onClick: () {
            widget.onTapConversation(widget.currentConversation, message);
          },
        ),
      );
    }).toList();
    return listWidget;
  }

  updateMsgResult(String? keyword, bool isNewSearch) {
    if (isNewSearch) {
      setState(() {
        currentPage = 0;
        keywordState = keyword!;
      });
    }
    model.getMsgForConversation(keyword ?? keywordState,
        widget.currentConversation.conversationID, currentPage);
    setState(() {
      currentPage = currentPage + 1;
    });
  }

  Widget _renderShowALl(bool isShowMore) {
    return (isShowMore == true)
        ? Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: TIMUIKitSearchShowALl(
              textShow: TIM_t("更多聊天记录"),
              onClick: () => {updateMsgResult(null, false)},
            ),
          )
        : Container();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    if (PlatformUtils().isWeb) {
      return TIMUIKitSearchNotSupport();
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
            value: serviceLocator<TUISearchViewModel>())
      ],
      builder: (context, w) {
        final List<V2TimMessage> currentMsgListForConversation =
            Provider.of<TUISearchViewModel>(context)
                .currentMsgListForConversation;
        final int totalMsgInConversationCount =
            Provider.of<TUISearchViewModel>(context)
                .totalMsgInConversationCount;
        return GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Scaffold(
              body: Column(
            children: [
              TIMUIKitSearchInput(
                onChange: (String value) {
                  updateMsgResult(value, true);
                },
                initValue: widget.keyword,
                prefixText: Text(
                  widget.currentConversation.showName ??
                      widget.currentConversation.userID ??
                      "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                  child: ListView(
                children: [
                  ..._renderListMessage(currentMsgListForConversation, context),
                  _renderShowALl(keywordState.isNotEmpty &&
                      totalMsgInConversationCount >
                          currentMsgListForConversation.length)
                ],
              )),
            ],
          )),
        );
      },
    );
  }
}
