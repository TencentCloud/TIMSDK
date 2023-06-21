package com.tencent.qcloud.tuicore.util;

import android.content.Context;
import com.tencent.qcloud.tuicore.R;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

public class DateTimeUtil {
    private static final long minute = 60 * 1000;
    private static final long hour = 60 * minute;
    private static final long day = 24 * hour;
    private static final long week = 7 * day;
    private static final long month = 31 * day;
    private static final long year = 12 * month;

    /**
     * return format text for time
     * you can see https://docs.oracle.com/javase/8/docs/api/java/util/Formatter.html
     * today：HH:MM
     * this week：Sunday, Friday ..
     * this year：MM/DD
     * before this year：YYYY/MM/DD
     * @param date current time
     * @return format text
     */
    public static String getTimeFormatText(Date date) {
        if (date == null) {
            return "";
        }
        Context context = TUIConfig.getAppContext();
        Locale locale;
        if (context == null) {
            locale = Locale.getDefault();
        } else {
            locale = TUIThemeManager.getInstance().getLocale(context);
        }
        String timeText;
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        calendar = Calendar.getInstance();
        calendar.set(Calendar.DAY_OF_WEEK, 1);
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        calendar = Calendar.getInstance();
        calendar.set(Calendar.DAY_OF_YEAR, 1);
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        long yearStartTimeInMillis = calendar.getTimeInMillis();
        long outTimeMillis = date.getTime();
        long weekStartTimeInMillis = calendar.getTimeInMillis();
        long dayStartTimeInMillis = calendar.getTimeInMillis();
        if (outTimeMillis < yearStartTimeInMillis) {
            timeText = String.format(locale, "%tD", date);
        } else if (outTimeMillis < weekStartTimeInMillis) {
            timeText = String.format(locale, "%1$tm/%1$td", date);
        } else if (outTimeMillis < dayStartTimeInMillis) {
            timeText = String.format(locale, "%tA", date);
        } else {
            timeText = String.format(locale, "%tR", date);
        }
        return timeText;
    }

    /**
     * HH:MM
     * @param date current time
     * @return format text e.g. "12:12"
     */
    public static String getHMTimeString(Date date) {
        if (date == null) {
            return "";
        }
        Context context = TUIConfig.getAppContext();
        Locale locale;
        if (context == null) {
            locale = Locale.getDefault();
        } else {
            locale = TUIThemeManager.getInstance().getLocale(context);
        }
        return String.format(locale, "%tR", date);
    }

    public static String formatSeconds(long seconds) {
        Context context = TUIConfig.getAppContext();
        String timeStr = seconds + context.getString(R.string.date_second_short);
        if (seconds > 60) {
            long second = seconds % 60;
            long min = seconds / 60;
            timeStr = min + context.getString(R.string.date_minute_short) + second + context.getString(R.string.date_second_short);
            if (min > 60) {
                min = (seconds / 60) % 60;
                long hour = (seconds / 60) / 60;
                timeStr = hour + context.getString(R.string.date_hour_short) + min + context.getString(R.string.date_minute_short) + second
                    + context.getString(R.string.date_second_short);
                if (hour % 24 == 0) {
                    long day = (((seconds / 60) / 60) / 24);
                    timeStr = day + context.getString(R.string.date_day_short);
                } else if (hour > 24) {
                    hour = ((seconds / 60) / 60) % 24;
                    long day = (((seconds / 60) / 60) / 24);
                    timeStr = day + context.getString(R.string.date_day_short) + hour + context.getString(R.string.date_hour_short) + min
                        + context.getString(R.string.date_minute_short) + second + context.getString(R.string.date_second_short);
                }
            }
        }
        return timeStr;
    }

    public static String formatSecondsTo00(int timeSeconds) {
        int second = timeSeconds % 60;
        int minuteTemp = timeSeconds / 60;
        if (minuteTemp > 0) {
            int minute = minuteTemp % 60;
            int hour = minuteTemp / 60;
            if (hour > 0) {
                return (hour >= 10 ? (hour + "") : ("0" + hour)) + ":" + (minute >= 10 ? (minute + "") : ("0" + minute)) + ":"
                    + (second >= 10 ? (second + "") : ("0" + second));
            } else {
                return (minute >= 10 ? (minute + "") : ("0" + minute)) + ":" + (second >= 10 ? (second + "") : ("0" + second));
            }
        } else {
            return "00:" + (second >= 10 ? (second + "") : ("0" + second));
        }
    }

    public static long getStringToDate(String dateString, String pattern) {
        SimpleDateFormat dateFormat = new SimpleDateFormat(pattern);
        Date date = new Date();
        try {
            date = dateFormat.parse(dateString);
        } catch (ParseException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return date.getTime();
    }

    public static String getTimeStringFromDate(Date date, String pattern) {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat(pattern);
        return simpleDateFormat.format(date);
    }
}
