// ignore_for_file: constant_identifier_names

import 'package:flutter/cupertino.dart';

enum ScreenType { Desktop, Tablet, Handset, Watch }

class FormFactor {
  static double desktop = 900;
  static double tablet = 600;
  static double handset = 300;
}

class ScreenUtils {
  static ScreenType getFormFactor(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.shortestSide;
    if (deviceWidth > FormFactor.desktop) return ScreenType.Desktop;
    if (deviceWidth > FormFactor.tablet) return ScreenType.Tablet;
    if (deviceWidth > FormFactor.handset) return ScreenType.Handset;
    return ScreenType.Watch;
  }
}
