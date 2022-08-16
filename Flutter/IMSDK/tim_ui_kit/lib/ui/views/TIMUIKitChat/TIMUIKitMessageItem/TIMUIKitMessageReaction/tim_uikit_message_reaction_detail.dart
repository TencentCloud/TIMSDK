import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';

class TIMUIKitMessageReactionDetail extends StatefulWidget {
  /// the index of the current emoji sticker
  final int currentStickerIndex;

  /// the list of member
  final List<V2TimGroupMemberFullInfo?>? memberList;

  /// message reaction map
  final Map<String, dynamic> messageReaction;

  /// the sticker list from message reaction
  final List<int> stickerList;

  const TIMUIKitMessageReactionDetail(
      {required this.currentStickerIndex,
      this.memberList,
      required this.messageReaction,
      Key? key,
      required this.stickerList})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => TIMUIKitMessageReactionDetailState();
}

class TIMUIKitMessageReactionDetailState
    extends TIMUIKitState<TIMUIKitMessageReactionDetail>
    with TickerProviderStateMixin {
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  final TUISelfInfoViewModel selfInfoModel =
      serviceLocator<TUISelfInfoViewModel>();

  Widget getUserItem(String userID, TUITheme theme) {
    V2TimGroupMemberFullInfo? memberInfo;
    String showName = userID;
    try {
      memberInfo =
          widget.memberList?.firstWhere((element) => element?.userID == userID);
      if (memberInfo != null) {
        showName = memberInfo.friendRemark ??
            memberInfo.nameCard ??
            memberInfo.nickName ??
            memberInfo.userID;
      }
    } catch (e) {
      // e
    }

    return GestureDetector(
      onTap: () {
        if (model.onTapAvatar != null) {
          if (userID != selfInfoModel.loginInfo?.userID) {
            model.onTapAvatar!(userID);
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: theme.weakDividerColor ??
                        CommonColor.weakDividerColor))),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: SizedBox(
                height: 40,
                width: 40,
                child: (memberInfo?.faceUrl != null)
                    ? Avatar(faceUrl: memberInfo!.faceUrl!, showName: userID)
                    : Container(),
              ),
            ),
            Expanded(
                child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 20, bottom: 20, right: 28),
              child: Text(
                showName,
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget stickerItem(int sticker, int length) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 12),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 1),
      decoration: const BoxDecoration(
        color: Color(0x198a8a8a),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              String.fromCharCode(sticker),
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 6),
            child: Text(length.toString()),
          ),
        ],
      ),
    );
  }

  Widget getStickerNameList(int sticker, TUITheme theme) {
    final nameList = widget.messageReaction[sticker.toString()];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [...nameList.map((e) => getUserItem(e, theme))],
      ),
    );
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final theme = value.theme;
    return DefaultTabController(
      initialIndex: widget.currentStickerIndex,
        length: widget.stickerList.length,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                child: TabBar(
                  isScrollable: true,
                  labelColor: theme.primaryColor,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelColor: hexToColor("62626b"),
                  unselectedLabelStyle:
                      const TextStyle(fontWeight: FontWeight.normal),
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: theme.primaryColor ?? hexToColor("62626b"),
                  tabs: [
                    ...widget.stickerList.map((element) {
                      return stickerItem(element,
                          widget.messageReaction[element.toString()].length);
                    })
                  ],
                ),
              ),
              Expanded(
                  child: TabBarView(
                      children: widget.stickerList
                          .map((int sticker) =>
                              getStickerNameList(sticker, theme))
                          .toList()))
            ],
          ),
        ));
  }
}
