import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_conversation_controller.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/tim_uikit_search.dart';
import 'package:timuikit/src/chat.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:provider/provider.dart';
import 'package:timuikit/src/provider/theme.dart';

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

  void _handleOnConvItemTapedWithPlace(V2TimConversation? selectedConv,
      [int? timestamp]) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Chat(
            selectedConversation: selectedConv!,
            initFindingTimestamp: timestamp,
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

  Widget searchEntry(TUITheme theme) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TIMUIKitSearch(
                  onTapConversation: _handleOnConvItemTapedWithPlace),
            ));
      },
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
              theme.primaryColor ?? CommonColor.primaryColor
            ]),
            boxShadow: [
              BoxShadow(
                color: theme.weakDividerColor ?? hexToColor("E6E9EB"),
                offset: const Offset(0.0, 2.0),
              )
            ]),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 6, 0),
                  child: Icon(
                    Icons.search,
                    color: hexToColor("979797"),
                    size: 18,
                  ),
                ),
                Text(imt("搜索"),
                    style: TextStyle(
                      color: hexToColor("979797"),
                      fontSize: 14,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    return Column(
      children: [
        searchEntry(theme),
        Expanded(
            child: TIMUIKitConversation(
          onTapItem: _handleOnConvItemTaped,
          itemSlidableBuilder: _itemSlidableBuilder,
          controller: _controller,
          emptyBuilder: () {
            return Center(
              child: Text(imt("暂无会话")),
            );
          },
        ))
      ],
    );
  }
}
