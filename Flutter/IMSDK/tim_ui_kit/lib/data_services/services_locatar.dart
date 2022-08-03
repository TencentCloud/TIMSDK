import 'package:get_it/get_it.dart';
import 'package:tim_ui_kit/business_logic/listener_model/tui_group_listener_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_conversation_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_friendship_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/conversation/conversation_services.dart';
import 'package:tim_ui_kit/data_services/conversation/conversation_services_implements.dart';
import 'package:tim_ui_kit/data_services/core/core_services_implements.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services_implements.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import 'package:tim_ui_kit/data_services/group/group_services_implement.dart';
import 'package:tim_ui_kit/data_services/message/message_service_implement.dart';
import 'package:tim_ui_kit/data_services/message/message_services.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_search_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_self_info_view_model.dart';

final serviceLocator = GetIt.instance;
bool boolIsInitailized = false;

void setupServiceLocator() {
  if (!boolIsInitailized) {
    // services

    serviceLocator.registerSingleton<CoreServicesImpl>(CoreServicesImpl());
    serviceLocator
        .registerSingleton<TUISelfInfoViewModel>(TUISelfInfoViewModel());
    serviceLocator
        .registerSingleton<ConversationService>(ConversationServicesImpl());
    serviceLocator.registerSingleton<MessageService>(MessageServiceImpl());
    serviceLocator
        .registerSingleton<FriendshipServices>(FriendshipServicesImpl());
    serviceLocator.registerSingleton<GroupServices>(GroupServicesImpl());

    // view models
    serviceLocator.registerSingleton<TUIChatViewModel>(TUIChatViewModel());
    serviceLocator.registerSingleton<TUIConversationViewModel>(
        TUIConversationViewModel());
    serviceLocator
        .registerSingleton<TUIFriendShipViewModel>(TUIFriendShipViewModel());
    serviceLocator.registerSingleton<TUIThemeViewModel>(TUIThemeViewModel());
    serviceLocator.registerSingleton<TUISearchViewModel>(TUISearchViewModel());

    // listener models
    serviceLocator.registerSingleton<TUIGroupListenerModel>(
        TUIGroupListenerModel());
    boolIsInitailized = true;
  }
}
