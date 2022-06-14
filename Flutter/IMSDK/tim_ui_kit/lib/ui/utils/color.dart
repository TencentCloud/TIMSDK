import 'package:flutter/material.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';

Color hexToColor(String hexString) {
  return Color(int.parse(hexString, radix: 16)).withAlpha(255);
}

class CommonColor {
  static const weakBackgroundColor = Color(0xFFEDEDED);
  static const weakDividerColor = Color(0xFFE5E6E9);
  static const primaryColor = Color(0xFF147AFF);
  static const lightPrimaryColor = Color(0xFFC0E1FF);
  static const secondaryColor = Color(0xFF147AFF);
  static const weakTextColor = Color(0xFF999999);
  static const infoColor = Color(0xFFFF9C19);
  static const cautionColor = Color(0xFFFF584C);
  static const ownerColor = Colors.orange;
  static const adminColor = Colors.blue;

  static const defaultTheme = TUITheme(
      weakBackgroundColor: Color(0xFFEDEDED),
      weakDividerColor: Color(0xFFE5E6E9),
      primaryColor: Color(0xFF147AFF),
      secondaryColor: Color(0xFF147AFF),
      infoColor: Color(0xFFFF9C19),
      lightPrimaryColor: Color(0xFFC0E1FF),
      weakTextColor: Color(0xFF999999),
      darkTextColor: Color(0xFF444444),
      cautionColor: Color(0xFFFF584C),
      ownerColor: Colors.orange,
      adminColor: Colors.blue);
}
