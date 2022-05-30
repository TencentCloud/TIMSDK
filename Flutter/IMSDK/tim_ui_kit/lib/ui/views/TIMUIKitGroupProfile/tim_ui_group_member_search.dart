import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';
import 'package:tim_ui_kit/ui/utils/optimize_utils.dart';

class GroupMemberSearchTextField extends StatelessWidget {
  final Function(String text) onTextChange;
  const GroupMemberSearchTextField({Key? key, required this.onTextChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var debounceFunc = OptimizeUtils.debounce(
        (text) => onTextChange(text), const Duration(milliseconds: 300));
    return ChangeNotifierProvider.value(
        value: serviceLocator<TUIThemeViewModel>(),
        child: Consumer<TUIThemeViewModel>(builder: (context, value, child) {
          final I18nUtils ttBuild = I18nUtils(context);
          final theme = value.theme;

          return Container(
            color: Colors.white,
            child: Column(children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(
                        color: theme.weakBackgroundColor!, width: 12)),
                child: TextField(
                  onChanged: debounceFunc,
                  decoration: InputDecoration(
                    hintText: ttBuild.imt("搜索"),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              Divider(
                  thickness: 1,
                  indent: 74,
                  endIndent: 0,
                  color: theme.weakBackgroundColor,
                  height: 0)
            ]),
          );
        }));
  }
}
