import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/enum/receive_message_opt_enum.dart';

import 'const.dart';

class CommonUtils {
  static bool isReceivingAndNotifingMessage(int recvOpt) {
    return ReceiveMsgOptEnum.values[recvOpt] ==
        ReceiveMsgOptEnum.V2TIM_RECEIVE_MESSAGE;
  }

  static String formatTime(int time) {
    List<int> times = [];
    if (time <= 0) return '0:00';
    if (time >= Const.DAY_SEC) return '1d+';
    for (int idx = 0; idx < Const.SEC_SERIES.length; idx++) {
      int sec = Const.SEC_SERIES[idx];
      if (time >= sec) {
        times.add((time / sec).floor());
        time = time % sec;
      } else if (idx > 0) {
        times.add(0);
      }
    }
    times.add(time);
    String formatTime = times[0].toString();
    for (int idx = 1; idx < times.length; idx++) {
      if (times[idx] < 10) {
        formatTime += ':0${times[idx].toString()}';
      } else {
        formatTime += ':${times[idx].toString()}';
      }
    }
    return formatTime;
  }
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}
