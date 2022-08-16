import 'package:flutter/cupertino.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_group_profile_model.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_ui_group_search_msg.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_uikit_group_add_opt.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_uikit_group_detail_card.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_uikit_group_manage.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_uikit_group_member_tile.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_uikit_group_message_disturb.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_uikit_group_name_card.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_uikit_group_notification.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_uikit_group_pin_conversation.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/widgets/tim_uikit_group_type.dart';

class TIMUIKitGroupProfileWidget {
  static Widget detailCard(
      {required V2TimGroupInfo groupInfo,

      /// You can deal with updating group name manually, or UIKIt do it automatically.
      Function(String updateGroupName)? updateGroupName}) {
    return GroupProfileDetailCard(
      groupInfo: groupInfo,
      updateGroupName: updateGroupName,
    );
  }

  static Widget memberTile() {
    return GroupMemberTile();
  }

  static Widget groupNotification() {
    return GroupProfileNotification();
  }

  static Widget groupManage(TUIGroupProfileModel model) {
    return GroupProfileGroupManage(model);
  }

  static Widget searchMessage(Function(V2TimConversation?) onJumpToSearch) {
    return GroupProfileGroupSearch(onJumpToSearch: onJumpToSearch);
  }

  static Widget operationDivider() {
    return const SizedBox(
      height: 10,
    );
  }

  static Widget groupType() {
    return GroupProfileType();
  }

  static Widget groupAddOpt() {
    return GroupProfileAddOpt();
  }

  static Widget nameCard() {
    return GroupProfileNameCard();
  }

  static Widget messageDisturb() {
    return GroupMessageDisturb();
  }

  static Widget pinedConversation() {
    return GroupPinConversation();
  }
}
