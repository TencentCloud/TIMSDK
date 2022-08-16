import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/TIMUIKitMessageReaction/tim_uikit_message_reaction_detail.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/TIMUIKitMessageReaction/tim_uikit_message_reaction_show_item.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/tim_uikit_cloud_custom_data.dart';

class TIMUIKitMessageReactionShowPanel extends TIMUIKitStatelessWidget {
  /// current message
  final V2TimMessage message;

  TIMUIKitMessageReactionShowPanel({required this.message, Key? key})
      : super(key: key);

  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();
  final TUISelfInfoViewModel selfInfoModel =
      serviceLocator<TUISelfInfoViewModel>();

  void showMore(
      BuildContext context,
      List<V2TimGroupMemberFullInfo?>? memberList,
      Map<String, dynamic> messageReaction,
      int currentSticker,
      List<int> stickerList) async {
    _showCustomModalBottomSheet(
        context, memberList, messageReaction, currentSticker, stickerList);
  }

  Future<Future<int?>> _showCustomModalBottomSheet(
      context,
      List<V2TimGroupMemberFullInfo?>? memberList,
      Map<String, dynamic> messageReaction,
      int currentSticker,
      List<int> stickerList) async {
    return showModalBottomSheet<int>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.66,
            minHeight: MediaQuery.of(context).size.height * 0.2,
          ),
          child: Column(children: [
            SizedBox(
              height: 50,
              child: Stack(
                textDirection: TextDirection.rtl,
                children: [
                  Center(
                    child: Text(
                      TIM_t("回应详情"),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ],
              ),
            ),
            const Divider(height: 1.0),
            Expanded(
                child: TIMUIKitMessageReactionDetail(
              stickerList: stickerList,
              currentStickerIndex: stickerList
                  .indexWhere((element) => element == currentSticker),
              memberList: memberList,
              messageReaction: messageReaction,
            )),
          ]),
        );
      },
    );
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    Map<String, dynamic> messageReaction = {};
    CloudCustomData messageCloudCustomData;
    try {
      messageCloudCustomData =
          CloudCustomData.fromJson(json.decode(message.cloudCustomData!));
    } catch (e) {
      messageCloudCustomData = CloudCustomData();
    }

    if (messageCloudCustomData.messageReaction != null &&
        messageCloudCustomData.messageReaction!.isNotEmpty) {
      messageReaction = messageCloudCustomData.messageReaction!;
    } else {
      return const SizedBox(width: 0, height: 0);
    }

    final List<int> messageReactionStickerList = [];

    messageReaction.forEach((key, value) {
      messageReactionStickerList.add(int.parse(key));
    });

    final filteredMessageReactionStickerList =
        messageReactionStickerList.where((sticker) {
      if (messageReaction[sticker.toString()] == null ||
          messageReaction[sticker.toString()] is! List ||
          messageReaction[sticker.toString()].length == 0) {
        return false;
      }
      return true;
    }).toList();

    final int convType = model.currentSelectedConvType ?? 1;
    List<V2TimGroupMemberFullInfo?> memberList = [];
    if (convType == 2) {
      memberList = model.groupMemberList;
    } else {
      final V2TimGroupMemberFullInfo selfInfo = V2TimGroupMemberFullInfo(
        userID: selfInfoModel.loginInfo?.userID ?? "",
        nickName: selfInfoModel.loginInfo?.nickName,
        faceUrl: selfInfoModel.loginInfo?.faceUrl,
      );

      final V2TimGroupMemberFullInfo targetInfo = V2TimGroupMemberFullInfo(
        userID: model.currentSelectedConv,
      );
      memberList = [selfInfo, model.currentChatUserInfo ?? targetInfo];
    }

    return filteredMessageReactionStickerList.isNotEmpty
        ? Container(
            margin: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: Platform.isAndroid ? 12 : 8,
              children: [
                ...filteredMessageReactionStickerList.map((sticker) {
                  return TIMUIKitMessageReactionShowItem(
                      memberList: memberList,
                      message: message,
                      nameList: messageReaction[sticker.toString()],
                      sticker: sticker,
                      onShowDetail: (int sticker) {
                        showMore(context, memberList, messageReaction, sticker,
                            filteredMessageReactionStickerList);
                      });
                }).toList(),
              ],
            ),
          )
        : const SizedBox(width: 0, height: 0);
  }
}
