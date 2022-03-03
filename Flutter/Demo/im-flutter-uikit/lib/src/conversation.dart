import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_conversation_controller.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/src/chat.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

class Conversation extends StatefulWidget {
  const Conversation({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  final TIMUIKitConversationController _controller =
      TIMUIKitConversationController();

  @override
  void initState() {
    super.initState();
    _controller.setConversationListener();
  }

  void _handleOnConvItemTaped(V2TimConversation? selectedConv) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Chat(
            selectedConversation: selectedConv!,
          ),
        ));
    _controller.reloadData();
  }

  _clearHistory(V2TimConversation conversationItem) {
    _controller.clearHistoryMessage(conversation: conversationItem);
  }

  _pinConversation(V2TimConversation conversation) {
    _controller.pinConversation(
        conversationID: conversation.conversationID,
        isPinned: !conversation.isPinned!);
  }

  List<ConversationItemSlidablePanel> _itemSlidableBuilder(
      V2TimConversation conversationItem) {
    return [
      ConversationItemSlidablePanel(
        onPressed: (context) {
          _clearHistory(conversationItem);
        },
        backgroundColor: hexToColor("006EFF"),
        foregroundColor: Colors.white,
        label: imt("清除聊天"),
        autoClose: true,
      ),
      ConversationItemSlidablePanel(
        onPressed: (context) {
          _pinConversation(conversationItem);
        },
        backgroundColor: hexToColor("FF9C19"),
        foregroundColor: Colors.white,
        label: conversationItem.isPinned! ? imt("取消置顶") : imt("置顶"),
      )
    ];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TIMUIKitConversation(
      onTapItem: _handleOnConvItemTaped,
      itemSlidableBuilder: _itemSlidableBuilder,
      controller: _controller,
      emptyBuilder: () {
        return Center(
          child: Text(imt("暂无会话")),
        );
      },
    );
  }
}
