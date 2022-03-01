import 'package:get_it/get_it.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_contact_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_conversation_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_new_contact_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_profile_view_model.dart';
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

final serviceLocator = GetIt.instance;
bool boolIsInitailized = false;

void setupServiceLocator() {
  if (!boolIsInitailized) {
    // services
    serviceLocator
        .registerSingleton<ConversationService>(ConversationServicesImpl());
    serviceLocator.registerSingleton<MessageService>(MessageServiceImpl());
    serviceLocator.registerSingleton<CoreServicesImpl>(CoreServicesImpl());
    serviceLocator
        .registerSingleton<FriendshipServices>(FriendshipServicesImpl());
    serviceLocator.registerSingleton<GroupServices>(GroupServicesImpl());

    // view models
    serviceLocator.registerSingleton<TUIChatViewModel>(TUIChatViewModel());
    serviceLocator.registerSingleton<TUIConversationViewModel>(
        TUIConversationViewModel());
    serviceLocator
        .registerSingleton<TUIProfileViewModel>(TUIProfileViewModel());
    serviceLocator
        .registerSingleton<TUIContactViewModel>(TUIContactViewModel());
    serviceLocator
        .registerSingleton<TUINewContactViewModel>(TUINewContactViewModel());
    serviceLocator.registerSingleton<TUIThemeViewModel>(TUIThemeViewModel());
    boolIsInitailized = true;
  }
}
