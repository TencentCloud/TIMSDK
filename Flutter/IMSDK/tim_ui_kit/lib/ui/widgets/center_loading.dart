import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class CenterLoading extends TIMUIKitStatelessWidget {
  CenterLoading({Key? key, this.messageID}) : super(key: key);
  final String? messageID;
  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
              value: serviceLocator<TUIChatViewModel>()),
        ],
        builder: (context, w) {
          final progress = Provider.of<TUIChatViewModel>(context)
              .getMessageProgress(messageID);
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
