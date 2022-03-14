import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/utils/theme.dart';

class DefaultThemeData with ChangeNotifier {
  ThemeType _currentThemeType = ThemeType.brisk;
  final CoreServicesImpl _coreInstance = TIMUIKitCore.getInstance();
  TUITheme _theme = CommonColor.defaultTheme;

  TUITheme get theme {
    return _theme;
  }

  set theme(TUITheme theme) {
    _theme = theme;
    notifyListeners();
  }

  ThemeType get currentThemeType => _currentThemeType;

  set currentThemeType(ThemeType type) {
    _currentThemeType = type;
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    _prefs.then((prefs) {
      prefs.setString("themeType", type.toString());
    });
    _coreInstance.setTheme(theme: DefTheme.defaultTheme[type]!);
    theme = DefTheme.defaultTheme[type]!;
    notifyListeners();
  }
}
