import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_search_view_model.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/tim_uikit_search_friend.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/pureUI/tim_uikit_search_input.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/tim_uikit_search_group.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/tim_uikit_search_msg.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class TIMUIKitSearch extends StatefulWidget {
  /// the callback after clicking the conversation item
  final Function(V2TimConversation, V2TimMessage?) onTapConversation;

  /// [Deprecated] : You are supposed to use [TIMUIKitSearchMsgDetail],
  /// if you tend to search inside a specific conversation, includes c2c and group.
  final V2TimConversation? conversation;

  /// [Deprecated] : You are supposed to use [onEnterSearchInConversation],
  /// though the effects are the same.
  final Function(V2TimConversation conversation, String initKeyword)?
      onEnterConversation;

  /// On click each conversation from 'Chat history' and searching for historical message in it.
  final Function(V2TimConversation conversation, String initKeyword)?
      onEnterSearchInConversation;

  const TIMUIKitSearch(
      {required this.onTapConversation,
      Key? key,
      @Deprecated("You are supposed to use [TIMUIKitSearchMsgDetail], if you tend to search inside a specific conversation, includes c2c and group")
          this.conversation,
      @Deprecated("You are supposed to use [onEnterSearchInConversation], though the effects are the same.")
          this.onEnterConversation,
      this.onEnterSearchInConversation})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => TIMUIKitSearchState();
}

class TIMUIKitSearchState extends TIMUIKitState<TIMUIKitSearch> {
  late TextEditingController textEditingController = TextEditingController();
  final model = serviceLocator<TUISearchViewModel>();
  GlobalKey<dynamic> inputTextField = GlobalKey();

  @override
  void initState() {
    super.initState();
    model.initSearch();
    model.initConversationMsg();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
            value: serviceLocator<TUISearchViewModel>())
      ],
      builder: (context, w) {
        List<V2TimFriendInfoResult>? friendResultList =
            Provider.of<TUISearchViewModel>(context).friendList;
        List<V2TimMessageSearchResultItem>? msgList =
            Provider.of<TUISearchViewModel>(context).msgList;
        List<V2TimGroupInfo>? groupList =
            Provider.of<TUISearchViewModel>(context).groupList;
        int totalMsgCount =
            Provider.of<TUISearchViewModel>(context).totalMsgCount;
        return GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TIMUIKitSearchInput(
                  key: inputTextField,
                  onChange: (String value) {
                    model.searchByKey(value);
                  },
                  controller: textEditingController,
                  prefixIcon: Icon(
                    Icons.search,
                    color: hexToColor("979797"),
                  ),
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TIMUIKitSearchFriend(
                          onTapConversation: widget.onTapConversation,
                          friendResultList: friendResultList ?? []),
                      TIMUIKitSearchGroup(
                          groupList: groupList ?? [],
                          onTapConversation: widget.onTapConversation),
                      TIMUIKitSearchMsg(
                        onTapConversation: widget.onTapConversation,
                        keyword: textEditingController.text,
                        totalMsgCount: totalMsgCount,
                        msgList: msgList ?? [],
                        onEnterConversation:
                            (V2TimConversation conversation, String keyword) {
                          if (widget.onEnterSearchInConversation != null) {
                            widget.onEnterSearchInConversation!(
                                conversation, keyword);
                          } else if (widget.onEnterConversation != null) {
                            widget.onEnterConversation!(conversation, keyword);
                          }
                        },
                      )
                    ],
                  ),
                ))
              ],
            ),
          ),
        );
      },
    );
  }
}
