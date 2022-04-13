# 主题方案
## 1 介绍
TUIKit 自定义了 **TUITheme** 类，用于规范TUIKit内的色彩使用。

请开发时务必注意，目前除 Colors.white 和 Colors.black 等底色/前景色外一律使用theme里提供的颜色。没有对应颜色可提出加到 TUITheme 里。

颜色概览：

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

  //除各种固定颜色外提供2种MaterialColor
  `primaryMaterialColor` && `lightPrimaryMaterialColor`。
  提供由 primaryColor 和 lightPrimaryColor 生成的十级色阶(50 ~ 900)，eg: `primaryMaterialColor.shade50` `primaryMaterialColor.shade900`

## 2 使用方式
### 2.1 开发中
#### 2.1.1 Demo

通过 provider 里的 **DefaultThemeData.theme** 来获取theme。

通过 provider 里的 **DefaultThemeData.currentThemeType** 来获取/设置当前ThemeType。

设置 **DefaultThemeData.currentThemeType** 会将currentThemeType 写入localStorage 并同步 TUIKit 的 Theme。

当前支持四种ThemeType：
`enum ThemeType { solemn, brisk, bright, fantasy }`

#### 2.1.2 UIKit

通过全局唯一的 `serviceLocator<TUIThemeViewModel>()` 获取当前 theme。

#### 2.1.3 AppBar

目前 **AppBar** 的统一处理如下：

字色目前统一为 Colors.white

`flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
              theme.primaryColor ?? CommonColor.primaryColor
            ]),
          ),
        ),`

`IconThemeData(
          color: Colors.white,
        ),`


## 3 TODO
3.1 目前只支持暗色底白字，需要提供亮/暗两种主题间的切换。

3.2 自动识别亮/暗主题并更改字色。