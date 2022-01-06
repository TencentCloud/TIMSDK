import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  // 先设置状态栏样式
  SystemUiOverlayStyle style = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  );
  SystemChrome.setSystemUIOverlayStyle(style);
  runApp(
    MaterialApp(
      home: Center(
        child: Text("demo&API Example 请在腾讯云即时通信IM官网下载"),
      ),
    ),
  );
}
