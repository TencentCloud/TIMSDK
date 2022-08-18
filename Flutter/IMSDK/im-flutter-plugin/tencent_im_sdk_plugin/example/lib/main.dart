import 'package:example/config/config.dart';
import 'package:example/custom_animation.dart';
import 'package:example/index/index.dart';
import 'package:example/provider/event.dart';
import 'package:example/provider/notice.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'i18n/strings.g.dart';
import 'package:statsfl/statsfl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();
  runApp(
    StatsFl(
        isEnabled: true, //Toggle on/off
        width: 600, //Set size
        height: 20, //
        maxFps: 90, // Support custom FPS target (default is 60)
        showText: true, // Hide text label
        sampleTime: .5, //Interval between fps calculations, in seconds.
        totalTime: 15, //Total length of timeline, in seconds.
        align: Alignment.topLeft, //Alignment of statsbox
        child: TranslationProvider(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Notice()),
          ChangeNotifierProvider(create: (_) => Event()),
        ],
        child: const APIExampleApp(),
      ),
    ))
  );
  configLoading();
}

class APIExampleApp extends StatelessWidget {
  const APIExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   
    return MaterialApp(
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: LocaleSettings.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      showPerformanceOverlay: true,
      home: const Index(),
      title: Config.appName,
      builder:   EasyLoading.init(),
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
