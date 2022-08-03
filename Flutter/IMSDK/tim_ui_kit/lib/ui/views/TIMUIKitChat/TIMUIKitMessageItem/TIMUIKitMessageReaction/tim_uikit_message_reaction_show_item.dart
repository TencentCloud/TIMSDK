// ignore_for_file: unused_field

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tim_ui_kit/data_services/message/message_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/TIMUIKitMessageReaction/tim_uikit_message_reaction_utils.dart';
import 'package:tim_ui_kit/ui/widgets/extended_wrap/extended_wrap.dart';

class TIMUIKitMessageReactionShowItem extends TIMUIKitStatelessWidget {
  /// the unicode of the emoji
  final int sticker;

  /// the list contains the name who choose the current emoji
  final List nameList;

  /// current message
  final V2TimMessage message;

  /// show the details of message reaction
  final Function(int sticker) onShowDetail;

  /// the member in current chat
  final List<V2TimGroupMemberFullInfo?> memberList;

  TIMUIKitMessageReactionShowItem(
      {required this.message,
      required this.sticker,
      required this.memberList,
      required this.onShowDetail,
      required this.nameList,
      Key? key})
      : super(key: key);

  final TUISelfInfoViewModel selfInfoModel =
      serviceLocator<TUISelfInfoViewModel>();
  final MessageService _messageService = serviceLocator<MessageService>();
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();

  clickOnCurrentSticker() async {
    for(int i = 0; i< 5; i++){
      final res = await modifySticker();
      if(res.code == 0){
        break;
      }
    }
  }

  Future<V2TimValueCallback<V2TimMessageChangeInfo>> modifySticker() async {
    return await Future.delayed(const Duration(milliseconds: 50), () async {
      return await MessageReactionUtils.clickOnSticker(message, sticker);
    });
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final theme = value.theme;
    final option1 = nameList.length;

    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10,),
      decoration: const BoxDecoration(
        color: Color(0x198a8a8a),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: clickOnCurrentSticker,
            child: Container(
              margin: EdgeInsets.only(
                  bottom: Platform.isAndroid ? 4 : 2,
                  top: Platform.isAndroid ? 4 : 0),
              child: Text(
                String.fromCharCode(sticker),
                style: TextStyle(
                  fontSize: Platform.isAndroid ? 12 : 16,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 6, right: 6),
            child: SizedBox(
              width: 1,
              height: 14,
              child: DecoratedBox(
                decoration: BoxDecoration(color: theme.weakTextColor),
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7 - 100,
            ),
            child: ExtendedWrap(
              maxLines: 1,
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              overflowWidget: GestureDetector(
                onTap: () {
                  onShowDetail(sticker);
                },
                child: Text(
                  TIM_t_para("...共{{option1}}人", "...共$option1人")(
                      option1: option1),
                  style: TextStyle(fontSize: 12,
                      color: hexToColor("616669")),
                ),
              ),
              children: [
                ...nameList.map((e) {
                  String showName = e;
                  if (memberList.isNotEmpty) {
                    try {
                      final V2TimGroupMemberFullInfo? memberInfo =
                          memberList
                              .firstWhere((element) => element?.userID == e);
                      if (memberInfo != null) {
                        if (memberInfo.friendRemark != null &&
                            memberInfo.friendRemark!.isNotEmpty) {
                          showName = memberInfo.friendRemark!;
                        } else if (memberInfo.nameCard != null &&
                            memberInfo.nameCard!.isNotEmpty) {
                          showName = memberInfo.nameCard!;
                        } else if (memberInfo.nickName != null &&
                            memberInfo.nickName!.isNotEmpty) {
                          showName = memberInfo.nickName!;
                        } else {
                          showName = memberInfo.userID;
                        }
                      }
                    } catch (e) {
                      // e
                    }
                  }
                  return GestureDetector(
                    onTap: () {
                      if (model.onTapAvatar != null) {
                        if (e != selfInfoModel.loginInfo?.userID) {
                          model.onTapAvatar!(e);
                        }
                      }
                    },
                    child: Text(
                      showName,
                      style: TextStyle(
                        fontSize: 12,
                          color: hexToColor("616669")
                      ),
                    ),
                  );
                })
              ],
            ),
          )
        ],
      ),
    );
  }
}
