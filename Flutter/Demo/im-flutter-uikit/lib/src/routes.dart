import 'package:flutter/material.dart';

class Routes extends ChangeNotifier {
  static String _pageType = "";
  Routes._internal();

  static late final Routes _instance = Routes._internal();

  factory Routes() {
    return _instance;
  }

  String get pageType {
    return _pageType;
  }

  directToHomePage() {
    _pageType = "homePage";
    notifyListeners();
  }

  directToLoginPage() {
    _pageType = "loginPage";
    notifyListeners();
  }
}
