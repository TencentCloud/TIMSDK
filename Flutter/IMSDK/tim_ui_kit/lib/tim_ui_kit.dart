library tim_ui_kit;

import 'package:tencent_im_base/tencent_im_base.dart';

import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'data_services/core/core_services_implements.dart';
export 'data_services/core/core_services_implements.dart';

// Global
export 'ui/utils/tui_theme.dart';

// Widgets
export 'package:tim_ui_kit/ui/views/TIMUIKitConversation/tim_uikit_conversation.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitChat/tim_uikit_chat.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitProfile/tim_uikit_profile.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitProfile/widget/tim_uikit_operation_item.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitContact/tim_uikit_contact.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitGroup/tim_uikit_group.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitBlackList/tim_uikit_black_list.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitNewContact/tim_uikit_new_contact.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitNewContact/tim_uikit_unread_count.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitGroupProfile/tim_uikit_group_profile.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_chat_history_message_list_item.dart';
export 'package:tim_ui_kit/ui/widgets/unread_message.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitAddFriend/tim_uikit_add_friend.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitAddGroup/tim_uikit_add_group.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_more_panel.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitSearch/tim_uikit_search.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitSearch/tim_uikit_search_msg_detail.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_text_field_controller.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitAppBar/tim_uikit_appbar.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_chat_history_message_list.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_chat_history_message_list_item.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_text_field.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitGroup/tim_uikit_group_application_list.dart';
export 'package:tencent_im_base/tencent_im_base.dart';
export 'package:tim_ui_kit/ui/widgets/link_preview/models/link_preview_content.dart';
export 'package:tim_ui_kit/ui/views/TIMUIKitProfile/widget/tim_uikit_profile_userinfo_card.dart';

// Enum

export 'package:tim_ui_kit/ui/theme/tim_uikit_message_theme.dart';

// Controller
export 'package:tim_ui_kit/ui/controller/tim_uikit_profile_controller.dart';

// Config
export 'package:tim_ui_kit/ui/views/TIMUIKitChat/tim_uikit_chat_config.dart';
export 'package:permission_handler/permission_handler.dart';

class TIMUIKitCore {
  static CoreServicesImpl getInstance() {
    setupServiceLocator();
    return serviceLocator<CoreServicesImpl>();
  }

  static V2TIMManager getSDKInstance() {
    return TencentImSDKPlugin.v2TIMManager;
  }
}
