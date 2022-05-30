import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';

class TIMUIKitDraftText extends StatelessWidget {
  final BuildContext context;
  final String draftText;

  const TIMUIKitDraftText({
    Key? key,
    required this.context,
    required this.draftText,
  }) : super(key: key);

  String _getDraftShowText() {
    final I18nUtils ttBuild = I18nUtils(context);

    final draftShowText = ttBuild.imt("草稿");

    return '[$draftShowText] ';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(builder: (context, value, child) {
          final theme = value.theme;
          return Row(children: [
            Text(_getDraftShowText(),
                style: TextStyle(color: theme.cautionColor)),
            Expanded(
                child: Text(
              draftText,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  height: 1.5, color: theme.weakTextColor, fontSize: 14),
            )),
          ]);
        }));
  }
}
