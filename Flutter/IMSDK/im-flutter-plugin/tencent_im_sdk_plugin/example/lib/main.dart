import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  // Set the status bar style first
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
