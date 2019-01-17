package com.tencent.qcloud.uikit.common.utils;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

/**
 * Created by valxehuang on 2018/7/29.
 */

public class DateTimeUtil {

    private final static long minute = 60 * 1000;// 1分钟
    private final static long hour = 60 * minute;// 1小时
    private final static long day = 24 * hour;// 1天
    private final static long month = 31 * day;// 月
    private final static long year = 12 * month;// 年

    /**
     * 返回文字描述的日期
     *
     * @param date
     * @return
     */
    public static String getTimeFormatText(Date date) {
        if (date == null) {
            return null;
        }

        int currentDayIndex;
        int currentWeek;


        int msgDayIndex;
        int msgYear;
        int msgDayInWeek;
        int msgWeek;
        String msgTimeStr;
        Calendar calendar = Calendar.getInstance();
        currentDayIndex = calendar.get(Calendar.DAY_OF_YEAR);
        currentWeek = calendar.get(Calendar.WEEK_OF_YEAR);

        calendar.setTime(date);
        msgYear = calendar.get(Calendar.YEAR);
        msgDayIndex = calendar.get(Calendar.DAY_OF_YEAR);
        int msgMinute = calendar.get(Calendar.MINUTE);

        msgTimeStr = calendar.get(Calendar.HOUR_OF_DAY) + ":";
        if (msgMinute < 10) {
            msgTimeStr = msgTimeStr + "0" + msgMinute;
        } else {
            msgTimeStr = msgTimeStr + msgMinute;
        }
        msgDayInWeek = calendar.get(Calendar.DAY_OF_WEEK);
        msgWeek = calendar.get(Calendar.WEEK_OF_YEAR);

        if (currentDayIndex == msgDayIndex) {
            return msgTimeStr;
        } else {
            if (currentDayIndex - msgDayIndex == 1) {
                msgTimeStr = "昨天 " + msgTimeStr;
            } else if (currentDayIndex - msgDayIndex > 1) {
                //同一周的时间显示，0是周天，中国人的习惯是跨周了
                if (msgWeek == currentWeek && msgDayInWeek != 0) {
                    msgTimeStr = getWeekDay(msgDayInWeek) + " " + msgTimeStr;
                }
                //不同周显示具体月，日
                else {
                    msgTimeStr = calendar.get(Calendar.MONTH) + "月" + calendar.get(Calendar.DAY_OF_MONTH) + "日" + msgTimeStr + " ";
                }
            }
            //最后一种情况就是currentDayIndex<msgDayIndex,那只能是跨年了
            else {
                msgTimeStr = msgYear + "年" + calendar.get(Calendar.MONTH) + "月" + calendar.get(Calendar.DAY_OF_MONTH) + "日" + msgTimeStr + " ";
            }


        }
        return msgTimeStr;
    }


    private static String getWeekDay(int dayInWeek) {
        switch (dayInWeek) {
            case Calendar.SUNDAY:
                return "周日";
            case Calendar.MONDAY:
                return "周一";
            case Calendar.TUESDAY:
                return "周二";
            case Calendar.WEDNESDAY:
                return "周三";
            case Calendar.THURSDAY:
                return "周四";
            case Calendar.FRIDAY:
                return "周五";
            case Calendar.SATURDAY:
                return "周六";
        }
        return "";
    }
}
