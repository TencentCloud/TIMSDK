import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitSearch/tim_uikit_search.dart';

import 'package:tim_ui_kit/data_services/conversation/conversation_services.dart';
import '../../../tim_ui_kit.dart';
import '../../utils/color.dart';

class GroupProfileGroupSearch extends StatelessWidget {
  final Function(V2TimConversation, int?) onTapConversation;
  GroupProfileGroupSearch({Key? key, required this.onTapConversation}) : super(key: key);
  final ConversationService _conversationService = serviceLocator<ConversationService>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(builder: (context, value, child) {
          final I18nUtils ttBuild = I18nUtils(context);
          final theme = value.theme;
          final model = SharedDataWidget.of(context)?.model;
          if (model == null) {
            return Container();
          }
          return InkWell(
            onTap: () async {
              V2TimConversation? conversation = await _conversationService.getConversation(conversationID: "group_${model.groupInfo!.groupID}");
              if(conversation != null){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TIMUIKitSearch(
                          onTapConversation: onTapConversation,
                          conversation: conversation,
                        )));
              }
            },
            child: Container(
              padding: const EdgeInsets.only(top: 12, left: 16, bottom: 12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      bottom: BorderSide(
                          color: theme.weakDividerColor ??
                              CommonColor.weakDividerColor))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ttBuild.imt("查找聊天内容"),
                    style: TextStyle(fontSize: 16, color: theme.darkTextColor),
                  ),
                  Icon(Icons.keyboard_arrow_right, color: theme.weakTextColor)
                ],
              ),
            ),
          );
        }));
  }
}