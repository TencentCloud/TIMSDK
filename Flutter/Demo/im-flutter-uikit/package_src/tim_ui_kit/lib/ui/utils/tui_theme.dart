import 'dart:ui';

class TUITheme {
  const TUITheme(
      {this.primaryColor,
      this.secondaryColor,
      this.infoColor,
      this.weakBackgroundColor,
      this.weakDividerColor,
      this.weakTextColor,
      this.darkTextColor,
      this.lightPrimaryColor,
      this.textColor,
      this.cautionColor,
      this.ownerColor,
      this.adminColor});

  // 应用主色
  // Primary Color For The App
  final Color? primaryColor;
  // 应用次色
  // Secondary Color For The App
  final Color? secondaryColor;
  // 提示颜色，用于次级操作或提示
  // Info Color, Used For Secondary Action Or Info
  final Color? infoColor;
  // 浅背景颜色，比主背景颜色浅，用于填充缝隙或阴影
  // Weak Background Color, Lighter Than Main Background, Used For Marginal Space Or Shadowy Space
  final Color? weakBackgroundColor;
  // 浅分割线颜色，用于分割线或边框
  // Weak Divider Color, Used For Divider Or Border
  final Color? weakDividerColor;
  // 浅字色
  // Weak Text Color
  final Color? weakTextColor;
  // 深字色
  // Dark Text Color
  final Color? darkTextColor;
  // 浅主色，用于AppBar或Panels
  // Light Primary Color, Used For AppBar Or Several Panels
  final Color? lightPrimaryColor;
  // 字色
  // TextColor
  final Color? textColor;
  // 警示色，用于危险操作
  // Caution Color, Used For Warning Actions
  final Color? cautionColor;
  // 群主标识色
  // Group Owner Identification Color
  final Color? ownerColor;
  // 群管理员标识色
  // Group Admin Identification Color
  final Color? adminColor;

  static const TUITheme light = TUITheme();
  static const TUITheme dark = TUITheme();

  TUITheme.fromJson(Map<String, dynamic> json)
      : primaryColor = json['primaryColor'] as Color?,
        secondaryColor = json['secondaryColor'] as Color?,
        infoColor = json['infoColor'] as Color?,
        weakBackgroundColor = json['weakBackgroundColor'] as Color?,
        weakDividerColor = json['weakDividerColor'] as Color?,
        weakTextColor = json['weakTextColor'] as Color?,
        darkTextColor = json['darkTextColor'] as Color?,
        lightPrimaryColor = json['lightPrimaryColor'] as Color?,
        textColor = json['textColor'] as Color?,
        cautionColor = json['cautionColor'] as Color?,
        ownerColor = json['ownerColor'] as Color?,
        adminColor = json['adminColor'] as Color?;

  toJson() => <String, dynamic>{
        'primaryColor': primaryColor,
        'secondaryColor': secondaryColor,
        'infoColor': infoColor,
        'weakBackgroundColor': weakBackgroundColor,
        'weakDividerColor': weakDividerColor,
        'weakTextColor': weakTextColor,
        'darkTextColor': darkTextColor,
        'lightPrimaryColor': lightPrimaryColor,
        'textColor': textColor,
        'cautionColor': cautionColor,
        'ownerColor': ownerColor,
        'adminColor': adminColor
      };
}
