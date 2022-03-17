import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_autosize_screen/auto_size_util.dart';
// import 'package:flutter_autosize_screen/binding.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/custom_animation.dart';
import 'package:timuikit/i18n/strings.g.dart';
import 'package:timuikit/src/pages/app.dart';
import 'package:timuikit/src/provider/theme.dart';

import 'package:provider/provider.dart';

void main() {
  // 设置状态栏样式
  SystemUiOverlayStyle style = SystemUiOverlayStyle(
    statusBarColor: hexToColor('ededed'),
  );
  SystemChrome.setSystemUIOverlayStyle(style);
  // 全局loading
  configLoading();
  // AutoSizeUtil.setStandard(375, isAutoTextSize: true);
  // fast i18n use device locale
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
      // runAutoApp(
      TranslationProvider(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => DefaultThemeData())
          ],
          child: const TUIKitDemoApp(),
        ),
      ),
    );
  });

  // );
}

class TUIKitDemoApp extends StatelessWidget {
  const TUIKitDemoApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    return MaterialApp(
      locale: TranslationProvider.of(context).flutterLocale, // use provider
      supportedLocales: LocaleSettings.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        platform: TargetPlatform.iOS,
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          primary: theme.primaryColor,
        )),
      ),
      home: const MyApp(),
      builder: EasyLoading.init(),
    );
  }
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false
    ..customAnimation = CustomAnimation();
}
