import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_search_result_item.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_search_view_model.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/tim_uikit_search_friend.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/pureUI/tim_uikit_search_input.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/tim_uikit_search_group.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/tim_uikit_search_msg.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/tim_uikit_search_msg_detail.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import '../../utils/color.dart';

class TIMUIKitSearch extends StatefulWidget {
  final Function(V2TimConversation, int?) onTapConversation;
  final V2TimConversation? conversation;

  const TIMUIKitSearch({required this.onTapConversation, Key? key,
    this.conversation})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => TIMUIKitSearchState();
}

class TIMUIKitSearchState
    extends State<TIMUIKitSearch> {
  late TextEditingController textEditingController = TextEditingController();
  final model = serviceLocator<TUISearchViewModel>();
  GlobalKey<dynamic> inputTextField = GlobalKey();
  bool toConversation = false;


  @override
  void initState() {
    super.initState();
    model.initSearch();
    model.initConversationMsg();
    if(widget.conversation != null){
      setState(() {
        toConversation = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    return toConversation == false ? MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
            value: serviceLocator<TUIThemeViewModel>()),
        ChangeNotifierProvider.value(
            value: serviceLocator<TUISearchViewModel>())
      ],
      builder: (context, w) {
        final theme = Provider.of<TUIThemeViewModel>(context).theme;
        List<V2TimFriendInfoResult>? friendResultList =
            Provider.of<TUISearchViewModel>(context).friendList;
        List<V2TimMessageSearchResultItem>? msgList =
            Provider.of<TUISearchViewModel>(context).msgList;
        List<V2TimGroupInfo>? groupList =
        Provider.of<TUISearchViewModel>(context).groupList;
        int totalMsgCount =
            Provider.of<TUISearchViewModel>(context).totalMsgCount;
        return GestureDetector(
          onTap: (){
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Scaffold(
            appBar: AppBar(
                iconTheme: const IconThemeData(
                  color: Colors.white,
                ),
                elevation: 0,
                backgroundColor: theme.primaryColor,
                title: Text(
                  ttBuild.imt("全局搜索"),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                )),
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
                              msgList: msgList ?? [])
                        ],
                      ),
                    ))
              ],
            ),
          ),
        );
      },
    ): TIMUIKitSearchMsgDetail(
      currentConversation: widget.conversation!,
      keyword: "",
      onTapConversation: widget.onTapConversation,
    );
  }
}
