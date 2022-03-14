import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:timuikit/utils/theme.dart';

class SkinPage extends StatelessWidget {
  const SkinPage({Key? key}) : super(key: key);

  List<Widget> skinBuilder() => ThemeType.values
      .map((type) => SkinCube(
            currentThemeType: type,
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          shadowColor: theme.weakDividerColor,
          elevation: 1,
          title: Text(
            imt("更换皮肤"),
            style: const TextStyle(color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
                theme.primaryColor ?? CommonColor.primaryColor
              ]),
            ),
          ),
        ),
        body: Container(
            padding: const EdgeInsets.only(top: 16),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: theme.weakBackgroundColor,
            child: Wrap(
              spacing: 16.0, // 主轴(水平)方向间距
              runSpacing: 16.0, // 纵轴（垂直）方向间距
              alignment: WrapAlignment.center, //沿主轴方向居中
              children: skinBuilder(),
            )));
  }
}

class SkinCube extends StatelessWidget {
  final ThemeType currentThemeType;
  const SkinCube({Key? key, required this.currentThemeType}) : super(key: key);

  onThemeChanged(BuildContext context, ThemeType type) {
    if (currentThemeType != type) {
      Provider.of<DefaultThemeData>(context, listen: false).currentThemeType =
          currentThemeType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeType = Provider.of<DefaultThemeData>(context).currentThemeType;
    return SizedBox(
        height: 128,
        width: MediaQuery.of(context).size.width * 0.45,
        child: GestureDetector(
            onTap: () {
              onThemeChanged(context, themeType);
            },
            child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  gradient: LinearGradient(colors: [
                    DefTheme.defaultTheme[currentThemeType]!
                            .lightPrimaryColor ??
                        CommonColor.lightPrimaryColor,
                    DefTheme.defaultTheme[currentThemeType]!.primaryColor ??
                        CommonColor.primaryColor
                  ]),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Checkbox(
                          onChanged: (bool? value) {
                            if (value != null && value == true) {
                              onThemeChanged(context, themeType);
                            }
                          },
                          value: themeType == currentThemeType,
                          side: const BorderSide(color: Colors.white, width: 1),
                          shape: const CircleBorder()),
                    ),
                    Positioned(
                        bottom: 0,
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.45,
                            height: 32,
                            decoration: BoxDecoration(
                                color: Colors.black.withAlpha(64),
                                borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(8))),
                            child: Center(
                                child: Text(
                                    DefTheme
                                        .defaultThemeName[currentThemeType]!,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16)))))
                  ],
                ))));
  }
}
