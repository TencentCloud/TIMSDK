// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:intl/intl.dart';
import 'package:tencent_im_base/i18n/i18n_utils.dart';

class TimeAgo {
  List<String> dayMap() {
    return [
      TIM_t("昨天"),
      TIM_t("前天"),
    ];
  }

  List<String> daysMap() {
    return [
      TIM_t("星期天"),
      TIM_t("星期一"),
      TIM_t("星期二"),
      TIM_t("星期三"),
      TIM_t("星期四"),
      TIM_t("星期五"),
      TIM_t("星期六")
    ];
  }

  List<String> weekdayMap() {
    return [
      '',
      TIM_t("星期一"),
      TIM_t("星期二"),
      TIM_t("星期三"),
      TIM_t("星期四"),
      TIM_t("星期五"),
      TIM_t("星期六"),
      TIM_t("星期天")
    ];
  }

  String getYearMounthDate(DateTime dateTime) {
    String month = dateTime.month.toString();
    String date = dateTime.day.toString();
    return dateTime.year.toString() +
        '/' +
        (month.length == 1 ? '0' : '') +
        month +
        '/' +
        (date.length == 1 ? '0' : '') +
        date;
  }

  String getMounthDate(DateTime dateTime) {
    String month = dateTime.month.toString();
    String date = dateTime.day.toString();
    return (month.length == 1 ? '0' : '') +
        month +
        '/' +
        (date.length == 1 ? '0' : '') +
        date;
  }

  String getTimeStringForChat(int timeStamp) {
    final formatedTimeStamp = timeStamp * 1000;
    final DateTime date =
        DateTime.fromMillisecondsSinceEpoch(formatedTimeStamp);
    final currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
    final Duration duration = DateTime.now().difference(date);

    int diffDays = duration.inDays;
    final diffMinutes = duration.inMinutes;
    var res;

    // 一个礼拜之内
    if (diffDays > 0 && diffDays < 7) {
      final String formatTodayZero =
          DateFormat('yyyyMMdd').format(DateTime.now());
      final todayZero = DateTime.parse(formatTodayZero).millisecondsSinceEpoch;
      final todayDiff = currentTimeStamp - todayZero;

      final isTwoDay = todayDiff < (diffMinutes - diffDays * 1440) * 60000;
      if (isTwoDay) {
        diffDays = diffDays + 1;
      }

      if (diffDays <= 2) {
        res = dayMap()[diffDays - 1];
      } else {
        res = daysMap()[date.weekday];
      }
    } else if (diffDays >= 7) {
      //当年内
      if (date.year == DateTime.now().year) {
        res = getMounthDate(date);
      } else {
        res = getYearMounthDate(date);
      }
    } else {
      if (diffMinutes > 1) {
        if (diffMinutes < 60) {
          final String option2 = diffMinutes.toString();
          res = TIM_t_para("{{option2}} 分钟前", "$option2 分钟前")(option2: option2);
        } else {
          final prefix = date.hour > 12 ? TIM_t("下午") : TIM_t("上午");
          final timeStr = DateFormat('hh:mm').format(date);
          res = "$prefix $timeStr";
        }
      } else {
        res = TIM_t("现在");
      }
    }

    return res;
  }

  String getTimeForMessage(int timeStamp) {
    var nowTime = DateTime.now();
    nowTime = DateTime(nowTime.year, nowTime.month, nowTime.day);
    var ftime = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    var preFix = ftime.hour >= 12 ? TIM_t("下午") : TIM_t("上午");
    final timeStr = DateFormat('hh:mm').format(ftime);
    // 一年外 年月日 + 上/下午 + 时间 (12小时制)
    if (nowTime.year != ftime.year) {
      return '${DateFormat('yyyy-MM-dd').format(ftime)} $preFix $timeStr';
    }
    // 一年内一周外 月日 + 上/下午 + 时间 (12小时制）
    if (ftime.isBefore(nowTime.subtract(const Duration(days: 6)))) {
      return '${DateFormat('MM-dd').format(ftime)} $preFix $timeStr';
    }
    // 一周内一天外 星期 + 上/下午 + 时间 (12小时制）
    if (ftime.isBefore(nowTime.subtract(const Duration(days: 1)))) {
      return '${weekdayMap()[ftime.weekday]} $preFix $timeStr';
    }
    // 昨日 昨天 + 上/下午 + 时间 (12小时制)
    if (nowTime.day != ftime.day) {
      String option2 = '$preFix $timeStr';
      return TIM_t_para("昨天 {{option2}}", "昨天 $option2")(option2: option2);
    }
    // 同年月日 上/下午 + 时间 (12小时制)
    return '$preFix $timeStr';
  }
}
