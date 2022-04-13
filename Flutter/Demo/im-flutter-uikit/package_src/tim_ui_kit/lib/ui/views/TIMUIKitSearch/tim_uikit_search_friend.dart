import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/pureUI/tim_uikit_search_item.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/pureUI/tim_uikit_search_folder.dart';

import 'package:tim_ui_kit/business_logic/view_models/tui_search_view_model.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/pureUI/tim_uikit_search_showAll.dart';
import '../../../../tim_ui_kit.dart';
import '../../../i18n/i18n_utils.dart';

class TIMUIKitSearchFriend extends StatefulWidget {
  List<V2TimFriendInfoResult> friendResultList;
  final Function(V2TimConversation, int?) onTapConversation;

  TIMUIKitSearchFriend(
      {required this.friendResultList,
      Key? key,
      required this.onTapConversation})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => TIMUIKitSearchFriendState();
}

class TIMUIKitSearchFriendState extends State<TIMUIKitSearchFriend>{
  bool isShowAll = false;
  int defaultShowLines = 3;

  Widget _renderShowALl(int currentLines, I18nUtils ttBuild){
    return (isShowAll == false && currentLines > defaultShowLines) ? TIMUIKitSearchShowALl(
      textShow: ttBuild.imt("全部联系人"),
      onClick: () => setState(() {
        isShowAll = true;
      }),
    ) : Container();
  }

  @override
  Widget build(BuildContext context) {
    final I18nUtils ttBuild = I18nUtils(context);
    List<V2TimConversation?> _conversationList =
        Provider.of<TUISearchViewModel>(context).conversationList;

    List<V2TimFriendInfoResult> filteredFriendResultList = widget.friendResultList.where(
            (friend) {
          int index = _conversationList.indexWhere(
                  (conv) => friend.friendInfo?.userID == conv?.userID);
          return index == -1 ? false : true;
        }
    ).toList();

    List<V2TimFriendInfoResult> halfFilteredFriendResultList =
      isShowAll ? filteredFriendResultList :
        filteredFriendResultList.sublist(0, min(defaultShowLines, filteredFriendResultList.length));

    if (filteredFriendResultList.isNotEmpty) {
      return TIMUIKitSearchFolder(folderName: ttBuild.imt("联系人"),
          children: [
        ...halfFilteredFriendResultList.map((conv) {
          int convIndex = _conversationList
              .indexWhere((item) => conv.friendInfo?.userID == item?.userID);
          V2TimConversation conversation = _conversationList[convIndex]!;
          return TIMUIKitSearchItem(
            onClick: () {
              widget.onTapConversation(conversation, null);
            },
            faceUrl: conv.friendInfo?.userProfile?.faceUrl ?? "",
            showName: "",
            lineOne: conversation.showName ??
                conversation.userID ??
                conv.friendInfo?.userID ??
                "",
          );
        }).toList(),
            _renderShowALl(filteredFriendResultList.length, ttBuild),
      ]);
    } else {
      return Container();
    }
  }
}
