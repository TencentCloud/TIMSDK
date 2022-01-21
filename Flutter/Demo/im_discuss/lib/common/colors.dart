import 'dart:ui';

import 'package:discuss/common/hextocolor.dart';

class CommonColors {
  static const String textBasicColorHexString = '111111';
  static const String textWeakColorHexString = '999999';
  static const String borderColorHexString = 'ededed';
  static const String gapColorHexString = 'ededed';
  static const String themeColorHexString = 'EBF0F6'; // 006fff
  static const String wightColorHexString = 'ffffff';
  static const String redColor = 'FA5151';

  static getTextBasicColor() {
    return hexToColor(textBasicColorHexString);
  }

  static getTextWeakColor() {
    return hexToColor(textWeakColorHexString);
  }

  static getBorderColor() {
    return hexToColor(borderColorHexString);
  }

  static getGapColor() {
    return hexToColor(gapColorHexString);
  }

  static getThemeColor() {
    return hexToColor(themeColorHexString);
  }

  static getWitheColor() {
    return hexToColor(wightColorHexString);
  }

  static getReadColor() {
    return hexToColor(redColor);
  }

  static getThemeBlueColor() {
    return const Color(0xFF147AFF);
  }
}
