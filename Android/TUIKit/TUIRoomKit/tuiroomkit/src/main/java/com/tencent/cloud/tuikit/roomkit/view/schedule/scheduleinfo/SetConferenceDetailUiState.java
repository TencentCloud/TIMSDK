package com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo;

import java.util.Calendar;
import java.util.TimeZone;

public class SetConferenceDetailUiState {
    private static final int      INTERVAL         = 5;
    private static final int      MINUTE_UNITS     = 60 * 1000;
    public               String   conferenceName   = "";
    public               boolean  isSeatEnabled    = false;
    public               long     scheduleStartTime;
    public               int      scheduleDuration = 30 * 60 * 1000;
    public               TimeZone timeZone         = TimeZone.getDefault();

    public SetConferenceDetailUiState() {
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(System.currentTimeMillis());
        int currentMinute = calendar.get(Calendar.MINUTE);
        int offsetMinute = (currentMinute / INTERVAL + 1) * INTERVAL;
        calendar.set(Calendar.MINUTE, offsetMinute);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        scheduleStartTime = calendar.getTimeInMillis();
    }
}
