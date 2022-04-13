import 'package:intl/intl.dart';

import '../../i18n/i18n_utils.dart';

class TimeAgo {
  late I18nUtils ttBuild;
  TimeAgo(context){
    ttBuild = I18nUtils(context);
  }

  List<String> dayMap(){
    return [
      ttBuild.imt("昨天"),
      ttBuild.imt("前天"),
    ];
  }
  List<String> daysMap(){
    return [ttBuild.imt("星期天"), ttBuild.imt("星期一"), ttBuild.imt("星期二"), ttBuild.imt("星期三"), ttBuild.imt("星期四"), ttBuild.imt("星期五"), ttBuild.imt("星期六")];
  }
  List<String> weekdayMap(){
    return [
      '',
      ttBuild.imt("星期一"),
      ttBuild.imt("星期二"),
      ttBuild.imt("星期三"),
      ttBuild.imt("星期四"),
      ttBuild.imt("星期五"),
      ttBuild.imt("星期六"),
      ttBuild.imt("星期天")
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
    final Duration duration = DateTime.now().difference(date);

    final diffDays = duration.inDays;
    final diffMinutes = duration.inMinutes;
    var res;
    // 一个礼拜之内
    if (diffDays > 0 && diffDays < 7) {
      if (diffDays <= 2) {
        res = dayMap()[diffDays - 1];
      } else {
        res = daysMap()[date.weekday];
      }
    } else if (diffDays > 7) {
      //当年内
      if (date.year == DateTime.now().year) {
        res = getMounthDate(date);
      } else {
        res = getYearMounthDate(date);
      }
    } else {
      if (diffMinutes > 1) {
        if (diffMinutes < 60) {
          res = ttBuild.imt_para("{{diffMinutes}} 分钟前", "$diffMinutes 分钟前")(diffMinutes: diffMinutes);
        } else {
          final prefix = date.hour > 12 ? ttBuild.imt("下午") : ttBuild.imt("上午");
          final timeStr = DateFormat('hh:mm').format(date);
          res = "$prefix $timeStr";
        }
      } else {
        res = ttBuild.imt("现在");
      }
    }

    return res;
  }

  String getTimeForMessage(int timeStamp) {
    var nowTime = DateTime.now();
    nowTime = DateTime(nowTime.year, nowTime.month, nowTime.day);
    var ftime = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    var preFix = ftime.hour >= 12 ? ttBuild.imt("下午") : ttBuild.imt("上午");
    final timeStr = DateFormat('hh:mm').format(ftime);
    // 一年外 年月日 + 上/下午 + 时间 (12小时制)
    if (nowTime.year != ftime.year) {
      return '${DateFormat('yyyy-MM-dd').format(ftime)} $preFix $timeStr';
    }
    // 一年内一周外 月日 + 上/下午 + 时间 (12小时制）
    if (ftime.isBefore(nowTime.subtract(const Duration(days: 7)))) {
      return '${DateFormat('MM-dd').format(ftime)} $preFix $timeStr';
    }
    // 一周内一天外 星期 + 上/下午 + 时间 (12小时制）
    if (ftime.isBefore(nowTime.subtract(const Duration(days: 1)))) {
      return '${weekdayMap()[ftime.weekday]} $preFix $timeStr';
    }
    // 昨日 昨天 + 上/下午 + 时间 (12小时制)
    if (nowTime.day != ftime.day) {
      final String yesterday = '$preFix $timeStr';
      return ttBuild.imt_para("昨天 {{yesterday}}", "昨天 $yesterday")(yesterday: yesterday);
    }
    // 同年月日 上/下午 + 时间 (12小时制)
    return '$preFix $timeStr';
  }
}
