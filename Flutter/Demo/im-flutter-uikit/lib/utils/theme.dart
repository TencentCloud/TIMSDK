import 'dart:ui';

import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

enum ThemeType { solemn, brisk, bright, fantasy }

class DefTheme {
  static ThemeType themeTypeFromString(String str) {
    return ThemeType.values
        .firstWhere((e) => e.toString() == str, orElse: () => ThemeType.brisk);
  }

  static final Map<ThemeType, TUITheme> defaultTheme = {
    ThemeType.solemn: const TUITheme(
      primaryColor: Color(0xFF00449E),
      lightPrimaryColor: Color(0xFF3371CD),
    ),
    ThemeType.brisk: const TUITheme(
      primaryColor: Color(0xFF147AFF),
      lightPrimaryColor: Color(0xFFC0E1FF),
    ),
    ThemeType.bright: const TUITheme(
      primaryColor: Color(0xFFF38787),
      lightPrimaryColor: Color(0xFFFAE1B6),
    ),
    ThemeType.fantasy: const TUITheme(
      primaryColor: Color(0xFF8783F0),
      lightPrimaryColor: Color(0xFFAEB6F4),
    ),
  };

  static final Map<ThemeType, String> defaultThemeName = {
    ThemeType.solemn: imt("深沉"),
    ThemeType.brisk: imt("轻快"),
    ThemeType.bright: imt("明媚"),
    ThemeType.fantasy: imt("梦幻")
  };
}
