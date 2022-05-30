import 'package:flutter/material.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';

class TUIThemeViewModel extends ChangeNotifier {
  TUITheme _theme = CommonColor.defaultTheme;

  TUITheme get theme {
    return _theme;
  }

  set theme(TUITheme theme) {
    _theme = theme;
    notifyListeners();
  }
}
