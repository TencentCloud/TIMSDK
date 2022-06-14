import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

class CenterLoading extends StatelessWidget {
  const CenterLoading({Key? key, this.messageID}) : super(key: key);
  final String? messageID;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
              value: serviceLocator<TUIChatViewModel>()),
          ChangeNotifierProvider.value(
              value: serviceLocator<TUIThemeViewModel>())
        ],
        builder: (context, w) {
          final progress = Provider.of<TUIChatViewModel>(context)
              .getMessageProgress(messageID);
          final theme = Provider.of<TUIThemeViewModel>(context).theme;
          return progress == 0
              ? Container()
              : Center(
                  child: CircularProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation(theme.primaryColor)));
        });
  }
}
