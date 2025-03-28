package com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo;

import android.content.Context;
import android.view.View;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;
import com.tencent.cloud.tuikit.roomkit.view.schedule.wheelpicker.WheelPicker;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class SetConferenceStartTimeView extends BottomSheetDialog implements View.OnClickListener {
    private static final int                                  MAX_HOUR_VALUE      = 24;
    private static final int                                  MAX_MINUTE_VALUE    = 60;
    private static final int                                  MAX_YEAR_VALUE      = 365;
    private static final int                                  MINUTE_INTERVAL     = 5;
    private static final long                                 ONE_DAY_MILLISECOND = 24 * 60 * 60 * 1000;
    private static final String                               FORMAT_DATE         = "%02d%s%02d%s %s";
    private              Context                              mContext;
    private              LinearLayout                         mLayoutStartTimeConfirm;
    private              LinearLayout                         mLayoutStartTimeClose;
    private              WheelPicker                          mWpStartTimeDate;
    private              WheelPicker                          mWpStartTimeHour;
    private              WheelPicker                          mWpStartTimeMinute;
    private              Calendar                             mCalendar;
    private              List<String>                         mDateStringList     = new ArrayList<>();
    private              List<String>                         mHourStringList     = new ArrayList<>();
    private              List<String>                         mMinuteStringList   = new ArrayList<>();
    private              Map<Integer, String>                 mWeekDayStringMap   = new HashMap<>();
    private              Map<Integer, Map<String, Object>>    mDateDataMap        = new HashMap<>();
    private              int                                  mHourValue          = 0;
    private              int                                  mMinuteValue        = 0;
    private              int                                  mDatePosition       = 0;
    private              ScheduleConferenceStateHolder        mStateHolder;
    private final        Observer<SetConferenceDetailUiState> mStartTimeObserver  = this::updateView;
    private              String                               mConferenceId       = "";

    public SetConferenceStartTimeView(@NonNull Context context) {
        super(context, R.style.TUIRoomDialogFragmentTheme);
        setContentView(R.layout.tuiroomkit_view_start_time_select);
        mContext = context;
        mCalendar = Calendar.getInstance();
        initData();
        initView();
    }

    public void setStateHolder(ScheduleConferenceStateHolder stateHolder) {
        this.mStateHolder = stateHolder;
    }

    private void initView() {
        mLayoutStartTimeConfirm = findViewById(R.id.ll_start_time_confirm);
        mLayoutStartTimeConfirm.setOnClickListener(this);
        mLayoutStartTimeClose = findViewById(R.id.ll_start_time_close);
        mLayoutStartTimeClose.setOnClickListener(this);

        mWpStartTimeDate = findViewById(R.id.np_start_time_date);
        mWpStartTimeDate.setData(mDateStringList);
        mWpStartTimeHour = findViewById(R.id.np_start_time_hour);
        mWpStartTimeHour.setData(mHourStringList);
        mWpStartTimeMinute = findViewById(R.id.np_start_time_minute);
        mWpStartTimeMinute.setData(mMinuteStringList);
        mWpStartTimeMinute.setOnItemSelectedListener(new WheelPicker.OnItemSelectedListener() {
            @Override
            public void onItemSelected(WheelPicker wheelPicker, Object o, int position) {
                updateTimePosition(mWpStartTimeHour.getCurrentItemPosition(), position);
            }
        });

        mWpStartTimeHour.setOnItemSelectedListener(new WheelPicker.OnItemSelectedListener() {
            @Override
            public void onItemSelected(WheelPicker wheelPicker, Object o, int position) {
                updateTimePosition(position, mWpStartTimeMinute.getCurrentItemPosition());
            }
        });

        mWpStartTimeDate.setOnItemSelectedListener(new WheelPicker.OnItemSelectedListener() {
            @Override
            public void onItemSelected(WheelPicker wheelPicker, Object o, int position) {
                updateTimePosition(mWpStartTimeHour.getCurrentItemPosition(), mWpStartTimeMinute.getCurrentItemPosition());
            }
        });
    }

    private void initData() {
        mWeekDayStringMap.put(1, mContext.getString(R.string.tuiroomkit_sunday_text));
        mWeekDayStringMap.put(2, mContext.getString(R.string.tuiroomkit_monday_text));
        mWeekDayStringMap.put(3, mContext.getString(R.string.tuiroomkit_tuesday_text));
        mWeekDayStringMap.put(4, mContext.getString(R.string.tuiroomkit_wednesday_text));
        mWeekDayStringMap.put(5, mContext.getString(R.string.tuiroomkit_thursday_text));
        mWeekDayStringMap.put(6, mContext.getString(R.string.tuiroomkit_friday_text));
        mWeekDayStringMap.put(7, mContext.getString(R.string.tuiroomkit_saturday_text));

        long timestamp = System.currentTimeMillis();
        String monthUnit = mContext.getString(R.string.tuiroomkit_month_text);
        String dayUnit = mContext.getString(R.string.tuiroomkit_day_text);
        for (int position = 0; position < MAX_YEAR_VALUE; position++) {
            mCalendar.setTimeInMillis(timestamp);
            int year = mCalendar.get(Calendar.YEAR);
            int month = mCalendar.get(Calendar.MONTH) + 1;
            int day = mCalendar.get(Calendar.DAY_OF_MONTH);
            int week = mCalendar.get(Calendar.DAY_OF_WEEK);
            setDateDataMap(position, year, month, day);
            String dateText = String.format(Locale.getDefault(), FORMAT_DATE, month, monthUnit, day, dayUnit, mWeekDayStringMap.get(week));
            if (position == 0) {
                dateText = mContext.getString(R.string.tuiroomkit_today);
            }
            mDateStringList.add(dateText);

            timestamp += ONE_DAY_MILLISECOND;
            if (position < MAX_HOUR_VALUE) {
                String hour = mContext.getString(R.string.tuiroomkit_start_time_hour_text, position);
                mHourStringList.add(hour);
            }
            if (position % MINUTE_INTERVAL == 0 && (position < MAX_MINUTE_VALUE)) {
                String minute = mContext.getString(R.string.tuiroomkit_start_time_minute_text, position);
                mMinuteStringList.add(minute);
            }
        }
    }

    private void setDateDataMap(int position, int year, int month, int day) {
        Map<String, Object> dateMap = new HashMap<>();
        dateMap.put("year", year);
        dateMap.put("month", month);
        dateMap.put("day", day);
        mDateDataMap.put(position, dateMap);
    }

    @Override
    public void onClick(View view) {
        if (view.getId() == R.id.ll_start_time_close) {
            dismiss();
        } else if (view.getId() == R.id.ll_start_time_confirm) {
            mDatePosition = mWpStartTimeDate.getCurrentItemPosition();
            mHourValue = mWpStartTimeHour.getCurrentItemPosition();
            mMinuteValue = mWpStartTimeMinute.getCurrentItemPosition() * MINUTE_INTERVAL;
            long selectTimestamp = transDateToSystemCurrentTime(mDatePosition, mHourValue, mMinuteValue);
            if (selectTimestamp <= System.currentTimeMillis()) {
                RoomToast.toastLongMessageCenter(mContext.getString(R.string.tuiroomkit_start_time_earlier_than_current_time));
            } else {
                mStateHolder.updateScheduleStartTime(selectTimestamp);
                dismiss();
            }
        }
    }

    private long transDateToSystemCurrentTime(int datePosition, int hourPosition, int minutePosition) {
        mCalendar.setTimeInMillis(System.currentTimeMillis());
        int year = (int) mDateDataMap.get(datePosition).get("year");
        int month = (int) mDateDataMap.get(datePosition).get("month");
        int day = (int) mDateDataMap.get(datePosition).get("day");
        mCalendar.set(Calendar.YEAR, year);
        mCalendar.set(Calendar.MONTH, month - 1);
        mCalendar.set(Calendar.DAY_OF_MONTH, day);
        mCalendar.set(Calendar.HOUR_OF_DAY, hourPosition);
        mCalendar.set(Calendar.MINUTE, minutePosition);
        mCalendar.set(Calendar.SECOND, 0);
        mCalendar.set(Calendar.MILLISECOND, 0);
        return mCalendar.getTimeInMillis();
    }

    private int transMinuteToPosition(int minute) {
        int position = minute / MINUTE_INTERVAL;
        return (minute % MINUTE_INTERVAL != 0) ? position + 1 : position;
    }

    private boolean isToday(int currentMonth, int currentDay) {
        int datePosition = mWpStartTimeDate.getCurrentItemPosition();
        Map<String, Object> dateMap = mDateDataMap.get(datePosition);
        if (dateMap == null) {
            return false;
        }
        Integer selectMonth = (Integer) dateMap.get("month");
        Integer selectDay = (Integer) dateMap.get("day");
        if (selectMonth == null || selectDay == null) {
            return false;
        }
        return selectMonth.equals(currentMonth) && selectDay.equals(currentDay);
    }


    private void updateTimePosition(int selectHourPosition, int selectMinutePosition) {
        mCalendar.setTimeInMillis(System.currentTimeMillis());
        int currentMonth = mCalendar.get(Calendar.MONTH) + 1;
        int currentDay = mCalendar.get(Calendar.DAY_OF_MONTH);
        int currentHour = mCalendar.get(Calendar.HOUR_OF_DAY);
        int currentMinute = mCalendar.get(Calendar.MINUTE);
        boolean isUpdateTimePosition = (selectHourPosition * MAX_MINUTE_VALUE + selectMinutePosition * MINUTE_INTERVAL) < (currentHour * MAX_MINUTE_VALUE + currentMinute);
        if (isToday(currentMonth, currentDay) && isUpdateTimePosition) {
            mWpStartTimeHour.setSelectedItemPosition(currentHour);
            mWpStartTimeMinute.setSelectedItemPosition(transMinuteToPosition(currentMinute));
            RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_start_time_earlier_than_current_time));
        }
    }

    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
        mStateHolder.observeStartTime(mStartTimeObserver);
    }

    @Override
    public void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mStateHolder.removeStartTimeObserve(mStartTimeObserver);
    }

    private void updateView(SetConferenceDetailUiState uiState) {
        mCalendar.setTimeZone(uiState.timeZone);
        long timestamp = Math.max(uiState.scheduleStartTime, System.currentTimeMillis());
        mCalendar.setTimeInMillis(timestamp);
        mMinuteValue = mCalendar.get(Calendar.MINUTE);
        mHourValue = mCalendar.get(Calendar.HOUR_OF_DAY);
        int selectedMonth = mCalendar.get(Calendar.MONTH) + 1;
        int selectedDay = mCalendar.get(Calendar.DAY_OF_MONTH);
        int selectedYear = mCalendar.get(Calendar.YEAR);
        for (Map.Entry<Integer, Map<String, Object>> dateMap : mDateDataMap.entrySet()) {
            Map<String, Object> date = dateMap.getValue();
            Integer month = (Integer) date.get("month");
            Integer day = (Integer) date.get("day");
            Integer year = (Integer) date.get("year");
            if (month == null || day == null || year == null) {
                mDatePosition = 0;
                break;
            }
            if (year.equals(selectedYear) && month.equals(selectedMonth) && day == selectedDay) {
                mDatePosition = dateMap.getKey();
                break;
            }
        }
        mWpStartTimeMinute.setSelectedItemPosition(transMinuteToPosition(mMinuteValue));
        mWpStartTimeHour.setSelectedItemPosition(mHourValue);
        mWpStartTimeDate.setSelectedItemPosition(mDatePosition);
    }
}
