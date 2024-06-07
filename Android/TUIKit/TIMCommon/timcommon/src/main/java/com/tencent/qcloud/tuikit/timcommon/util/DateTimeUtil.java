package com.tencent.qcloud.tuikit.timcommon.util;

import android.content.Context;

import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.timcommon.R;

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
        Calendar dayStartCalendar = Calendar.getInstance();
        dayStartCalendar.set(Calendar.HOUR_OF_DAY, 0);
        dayStartCalendar.set(Calendar.MINUTE, 0);
        dayStartCalendar.set(Calendar.SECOND, 0);
        dayStartCalendar.set(Calendar.MILLISECOND, 0);
        Calendar weekStartCalendar = Calendar.getInstance();
        weekStartCalendar.setFirstDayOfWeek(Calendar.SUNDAY);
        weekStartCalendar.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);
        weekStartCalendar.set(Calendar.HOUR_OF_DAY, 0);
        weekStartCalendar.set(Calendar.MINUTE, 0);
        weekStartCalendar.set(Calendar.SECOND, 0);
        weekStartCalendar.set(Calendar.MILLISECOND, 0);
        Calendar yearStartCalendar = Calendar.getInstance();
        yearStartCalendar.set(Calendar.DAY_OF_YEAR, 1);
        yearStartCalendar.set(Calendar.HOUR_OF_DAY, 0);
        yearStartCalendar.set(Calendar.MINUTE, 0);
        yearStartCalendar.set(Calendar.SECOND, 0);
        yearStartCalendar.set(Calendar.MILLISECOND, 0);
        long dayStartTimeInMillis = dayStartCalendar.getTimeInMillis();
        long weekStartTimeInMillis = weekStartCalendar.getTimeInMillis();
        long yearStartTimeInMillis = yearStartCalendar.getTimeInMillis();
        long outTimeMillis = date.getTime();
        if (outTimeMillis < yearStartTimeInMillis) {
            timeText = String.format(Locale.US, "%tD", date);
        } else if (outTimeMillis < weekStartTimeInMillis) {
            timeText = String.format(Locale.US, "%1$tm/%1$td", date);
        } else if (outTimeMillis < dayStartTimeInMillis) {
            timeText = String.format(locale, "%tA", date);
        } else {
            timeText = String.format(Locale.US, "%tR", date);
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
        return String.format(Locale.US, "%tR", date);
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
        SimpleDateFormat dateFormat = new SimpleDateFormat(pattern, Locale.US);
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
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat(pattern, Locale.US);
        return simpleDateFormat.format(date);
    }
}
