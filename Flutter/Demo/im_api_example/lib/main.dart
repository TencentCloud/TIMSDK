import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:im_api_example/config/config.dart';
import 'package:im_api_example/custom_animation.dart';
import 'package:im_api_example/index/index.dart';
import 'package:im_api_example/provider/event.dart';
import 'package:im_api_example/provider/notice.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Notice()),
        ChangeNotifierProvider(create: (_) => Event()),
      ],
      child: MaterialApp(
        title: Config.appName,
        home: Index(),
        builder: EasyLoading.init(),
      ),
    ),
  );
  configLoading();
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
