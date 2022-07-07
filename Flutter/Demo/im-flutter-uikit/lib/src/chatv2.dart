import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_chat_controller.dart';

class ChatV2 extends StatefulWidget {
  final V2TimConversation selectedConversation;
  final V2TimMessage? initFindingMsg;

  const ChatV2(
      {Key? key, required this.selectedConversation, this.initFindingMsg})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _ChatV2State();
}

class _ChatV2State extends State<ChatV2> {
  final TIMUIKitChatController _controller = TIMUIKitChatController();
  final TIMUIKitHistoryMessageListController _historyMessageListController =
      TIMUIKitHistoryMessageListController();
  final TIMUIKitInputTextFieldController _textFieldController =
      TIMUIKitInputTextFieldController();
  bool _haveMoreData = true;
  String? _getConvID() {
    return widget.selectedConversation.type == 1
        ? widget.selectedConversation.userID
        : widget.selectedConversation.groupID;
  }

  loadHistoryMessageList(String? lastMsgID, [int? count]) async {
    if (_haveMoreData) {
      _haveMoreData = await _controller.loadHistoryMessageList(
          count: count ?? 20,
          userID: widget.selectedConversation.userID,
          groupID: widget.selectedConversation.groupID,
          lastMsgID: lastMsgID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TIMUIKitChatProviderScope(
      conversationID: _getConvID() ?? "",
      conversationType: widget.selectedConversation.type ?? 0,
      builder: (context, w) {
        return GestureDetector(
          onTap: () {
            _textFieldController.hideAllPanel();
          },
          child: Scaffold(
            appBar: TIMUIKitAppBar(
              config: AppBar(
                title: Text(widget.selectedConversation.showName ?? ""),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                    child: TIMUIKitHistoryMessageListSelector(
                  builder: (context, messageList, w) {
                    return TIMUIKitHistoryMessageList(
                      controller: _historyMessageListController,
                      messageList: messageList,
                      onLoadMore: loadHistoryMessageList,
                      itemBuilder: (context, message) {
                        return TIMUIKitHistoryMessageListItem(
                          // messageItemBuilder: MessageItemBuilder(
                          //   textReplyMessageItemBuilder:
                          //       (message, isShowJump, clearJump) {},
                          // ),
                          // themeData: MessageThemeData(
                          //     messageBackgroundColor: Colors.black,
                          //     messageTextStyle: TextStyle(color: Colors.redAccent)),
                          topRowBuilder: (context, message) {
                            return Row(
                              children: const [Text("this is top Raw builder")],
                            );
                          },
                          showMessageReadRecipt: false,
                          onScrollToIndex:
                              _historyMessageListController.scrollToIndex,
                          onScrollToIndexBegin: _historyMessageListController
                              .scrollToIndexBegin,
                          // exteraTipsActionItemBuilder:
                          //     widget.exteraTipsActionItemBuilder,
                          message: message!,
                          // onTapAvatar: widget.onTapAvatar,
                          // showNickName: widget.showNickName,
                          // messageItemBuilder: widget.messageItemBuilder,
                          // onLongPressForOthersHeadPortrait:
                          //     widget.onLongPressForOthersHeadPortrait,
                          // onMsgSendFailIconTap: widget.onMsgSendFailIconTap,
                        );
                      },
                    );
                  },
                  conversationID: _getConvID() ?? "",
                )),
                TIMUIKitInputTextField(
                  controller: _textFieldController,
                  conversationID: _getConvID() ?? "",
                  conversationType: widget.selectedConversation.type ?? ConversationType.V2TIM_C2C,
                  scrollController:
                      _historyMessageListController.scrollController!,
                  hintText: "",
                  // showMorePannel: false,
                  // showSendAudio: false,
                  // showSendEmoji: false,
                )
              ],
            ),
            // body: Container(),
          ),
        );
      },
    );
  }
}
