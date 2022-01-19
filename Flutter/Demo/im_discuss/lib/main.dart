import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/custom_animation.dart';
import 'package:discuss/pages/home/home.dart';
import 'package:discuss/provider/config.dart';
import 'package:discuss/provider/conversationlistprovider.dart';
import 'package:discuss/provider/conversion.dart';
import 'package:discuss/provider/currentmessagelist.dart';
import 'package:discuss/provider/discuss_datas.dart';
import 'package:discuss/provider/friend.dart';
import 'package:discuss/provider/friendapplication.dart';
import 'package:discuss/provider/groupapplication.dart';
import 'package:discuss/provider/historymessagelistprovider.dart';
import 'package:discuss/provider/keybooadshow.dart';
import 'package:discuss/provider/multiselect.dart';
import 'package:discuss/provider/user.dart';
import 'package:discuss/provider/user_infos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_autosize_screen/auto_size_util.dart';
// import 'package:flutter_autosize_screen/binding.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
  runApp(
    // runAutoApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConversionModel()),
        ChangeNotifierProvider(create: (_) => UserModel()),
        ChangeNotifierProvider(create: (_) => CurrentMessageListModel()),
        ChangeNotifierProvider(create: (_) => FriendListModel()),
        ChangeNotifierProvider(create: (_) => FriendApplicationModel()),
        ChangeNotifierProvider(create: (_) => GroupApplicationModel()),
        ChangeNotifierProvider(create: (_) => KeyBoradModel()),
        ChangeNotifierProvider(create: (_) => AppConfig()),
        ChangeNotifierProvider(create: (_) => MultiSelect()),
        ChangeNotifierProvider(create: (_) => ConversationListProvider()),
        ChangeNotifierProvider(create: (_) => HistoryMessageListProvider()),
        ChangeNotifierProvider(create: (_) => UserInfos()),
        ChangeNotifierProvider(create: (_) => DiscussData()),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          // 本地化的代理类
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'), // 美国英语
          Locale('zh', 'CN'), // 中文简体
        ],
        theme: ThemeData(
          platform: TargetPlatform.iOS,
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          }),
        ),
        home: const HomePage(),
        builder: EasyLoading.init(),
      ),
    ),
  );
  // );
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
