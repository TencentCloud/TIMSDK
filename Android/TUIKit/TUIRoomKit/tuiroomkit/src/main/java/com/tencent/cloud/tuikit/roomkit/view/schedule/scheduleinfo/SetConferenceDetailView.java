package com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo;

import android.content.Context;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputFilter;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;
import com.tencent.cloud.tuikit.roomkit.view.schedule.selectscheduleparticipant.SelectScheduleParticipantView;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.trtc.tuikit.common.livedata.Observer;

import java.nio.charset.StandardCharsets;
import java.util.Calendar;
import java.util.Locale;
import java.util.TimeZone;

public class SetConferenceDetailView extends FrameLayout {
    public static final  int                           MILLISECONDS_IN_ONE_HOUR   = 60 * 60 * 1000;
    public static final  int                           MILLISECONDS_IN_ONE_MINUTE = 60 * 1000;
    private static final String                        TIME_ZONE_ID               = "TIME_ZONE_ID";
    private static final String                        FORMAT_DATE                = "%d%s%02d%s%02d%s %02d:%02d";
    private static final String                        FORMAT_ZONE                = "(%s) %s";
    private              Context                       mContext;
    private              LinearLayout                  mLayoutConferenceType;
    private              ConstraintLayout              mLayoutConferenceStartTime;
    private              ConstraintLayout              mLayoutConferenceDuration;
    private              ConstraintLayout              mLayoutTimeZone;
    private              SelectScheduleParticipantView mSelectScheduleParticipantView;
    private              TextView                      mTvConferenceType;
    private              TextView                      mTvRoomDuration;
    private              TextView                      mTvTimeZone;
    private              TextView                      mTvStartTime;
    private              EditText                      mEditTextRoomName;
    private              SetConferenceTypeView         mConferenceTypeSelect;
    private              SetConferenceDurationView     mConferenceDurationSelect;
    private              SetConferenceStartTimeView    mConferenceStartTimeView;

    private String mConferenceId = "";

    private       ScheduleConferenceStateHolder        mStateHolder;
    private final Observer<SetConferenceDetailUiState> mDetailObserver = this::updateView;

    public SetConferenceDetailView(@NonNull Context context) {
        super(context);
        mContext = context;
        initView();
    }

    public void setStateHolder(ScheduleConferenceStateHolder stateHolder) {
        mStateHolder = stateHolder;
        mSelectScheduleParticipantView.setStateHolder(stateHolder);
        mStateHolder.updateConferenceName(mContext.getString(R.string.tuiroomkit_temporary_conference_name, TUILogin.getNickName()));
    }

    public void setConferenceId(String conferenceId) {
        mConferenceId = conferenceId;
    }

    public void disableSetConferenceType() {
        if (mLayoutConferenceType != null) {
            mLayoutConferenceType.setClickable(false);
            ImageView icon = findViewById(R.id.image_conference_type_icon);
            icon.setVisibility(GONE);
        }
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        mStateHolder.observeDetail(mDetailObserver, mConferenceId);
        mConferenceStartTimeView.setStateHolder(mStateHolder);
        mConferenceDurationSelect.setStateHolder(mStateHolder);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mStateHolder.removeDetailObserver(mDetailObserver);
    }

    private void initView() {
        addView(LayoutInflater.from(mContext).inflate(R.layout.tuiroomkit_view_set_conference_detail, this, false));
        initConferenceNameView();
        initConferenceTypeView();
        initConferenceStartTimeView();
        initConferenceDurationView();
        initConferenceTimeZoneView();
        mSelectScheduleParticipantView = findViewById(R.id.tuiroomkit_select_schedule_participant);
    }

    public void initConferenceNameView() {
        InputFilter[] conferenceNameFilter = new InputFilter[]{new ConferenceNameMaxLength()};
        mEditTextRoomName = findViewById(R.id.tv_conference_name);
        mEditTextRoomName.setFilters(conferenceNameFilter);
        String conferenceName = mContext.getString(R.string.tuiroomkit_temporary_conference_name, TUILogin.getNickName());
        mEditTextRoomName.setText(conferenceName);
        mEditTextRoomName.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.length() > 0 && s.charAt(0) == ' ') {
                    s.delete(0, 1);
                }
                String content = mEditTextRoomName.getText().toString();
                if (!TextUtils.equals(content, mStateHolder.mConferenceDetailData.get().conferenceName)) {
                    mStateHolder.updateConferenceName(content);
                }
            }
        });
    }

    private class ConferenceNameMaxLength implements InputFilter {
        private static final int CONFERENCE_NAME_MAX_LENGTH = 100;

        @Override
        public CharSequence filter(CharSequence source, int start, int end, Spanned dest, int destStart, int destEnd) {
            int currentBytes = countBytes(dest.toString());
            int inputBytes = countBytes(source.toString().substring(start, end));
            int newBytes = currentBytes + inputBytes;
            if (newBytes > CONFERENCE_NAME_MAX_LENGTH) {
                RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_conference_name_exceeds_max_length));
                return "";
            }
            return null;
        }

        private int countBytes(String str) {
            return str.getBytes(StandardCharsets.UTF_8).length;
        }
    }

    public void initConferenceTypeView() {
        mLayoutConferenceType = findViewById(R.id.ll_conference_type);
        mTvConferenceType = findViewById(R.id.tv_conference_type);
        mConferenceTypeSelect = new SetConferenceTypeView(mContext);
        mConferenceTypeSelect.setSeatEnableCallback(new SetConferenceTypeView.SeatEnableCallback() {
            @Override
            public void onSeatEnableChanged(boolean enable) {
                mStateHolder.updateConferenceType(enable);
            }
        });
        mLayoutConferenceType.setOnClickListener(this::onClick);
    }

    public void initConferenceStartTimeView() {
        mLayoutConferenceStartTime = findViewById(R.id.ll_conference_start_time);
        mTvStartTime = findViewById(R.id.tv_conference_start_time);
        mLayoutConferenceStartTime.setOnClickListener(this::onClick);
        mConferenceStartTimeView = new SetConferenceStartTimeView(mContext);
    }

    public void initConferenceDurationView() {
        mLayoutConferenceDuration = findViewById(R.id.ll_conference_duration);
        mLayoutConferenceDuration.setOnClickListener(this::onClick);
        mTvRoomDuration = findViewById(R.id.tv_conference_duration);
        mConferenceDurationSelect = new SetConferenceDurationView(mContext);
    }

    public void initConferenceTimeZoneView() {
        mLayoutTimeZone = findViewById(R.id.ll_time_zone);
        mLayoutTimeZone.setOnClickListener(this::onClick);
        mTvTimeZone = findViewById(R.id.tv_time_zone);
        mLayoutTimeZone.setOnClickListener(this::onClick);
    }

    private String durationTransToString(int hour, int minutes) {
        String timeHour = "", timeMinutes = "";
        if (hour != 0) {
            timeHour = mContext.getString(R.string.tuiroomkit_hour_text, hour);
        }
        if (minutes != 0) {
            timeMinutes = mContext.getString(R.string.tuiroomkit_minute_text, minutes);
        }
        return timeHour + timeMinutes;
    }

    public void onClick(View view) {
        if (view.getId() == R.id.ll_conference_type) {
            if (mConferenceTypeSelect == null) {
                mConferenceTypeSelect = new SetConferenceTypeView(mContext);
            }
            mConferenceTypeSelect.show();
        } else if (view.getId() == R.id.ll_conference_duration) {
            if (mConferenceDurationSelect == null) {
                mConferenceDurationSelect = new SetConferenceDurationView(mContext);
            }
            mConferenceDurationSelect.show();
        } else if (view.getId() == R.id.ll_time_zone) {
            startTimeZoneActivity();
        } else if (view.getId() == R.id.ll_conference_start_time) {
            if (mConferenceStartTimeView == null) {
                mConferenceStartTimeView = new SetConferenceStartTimeView(mContext);
            }
            mConferenceStartTimeView.show();
        }
    }

    private void startTimeZoneActivity() {
        Bundle param = new Bundle();
        param.putString(TIME_ZONE_ID, mStateHolder.mConferenceDetailData.get().timeZone.getID());
        TUICore.startActivityForResult((AppCompatActivity) mContext, "TimeZoneActivity", param, result -> {
            if (result.getData() == null) {
                return;
            }
            String timeZoneId = result.getData().getStringExtra(TIME_ZONE_ID);
            mStateHolder.updateScheduleTimeZone(TimeZone.getTimeZone(timeZoneId));
        });
    }

    private void updateView(SetConferenceDetailUiState uiState) {
        mEditTextRoomName.setText(uiState.conferenceName);

        int resId = uiState.isSeatEnabled ? R.string.tuiroomkit_room_raise_hand : R.string.tuiroomkit_room_free_speech;
        mTvConferenceType.setText(resId);

        int millisecond = uiState.scheduleDuration;
        int hour = millisecond / MILLISECONDS_IN_ONE_HOUR;
        int minute = millisecond % MILLISECONDS_IN_ONE_HOUR / MILLISECONDS_IN_ONE_MINUTE;
        mTvRoomDuration.setText(durationTransToString(hour, minute));

        mTvTimeZone.setText(getTimeZoneText(uiState.timeZone.getID()));
        String startTimeText = getStartTimeText(uiState.scheduleStartTime, uiState.timeZone);
        mTvStartTime.setText(startTimeText);
    }

    private String getStartTimeText(long startTime, TimeZone timeZone) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeZone(timeZone);
        calendar.setTimeInMillis(startTime);
        int year = calendar.get(Calendar.YEAR);
        int month = calendar.get(Calendar.MONTH) + 1;
        int day = calendar.get(Calendar.DAY_OF_MONTH);
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        int minute = calendar.get(Calendar.MINUTE);
        String yearUnit = mContext.getString(R.string.tuiroomkit_year_text);
        String monthUnit = mContext.getString(R.string.tuiroomkit_month_text);
        String dayUnit = mContext.getString(R.string.tuiroomkit_day_text);
        return String.format(Locale.getDefault(), FORMAT_DATE, year, yearUnit, month, monthUnit, day, dayUnit, hour, minute);
    }

    private String getTimeZoneText(String id) {
        TimeZone timeZone = TimeZone.getTimeZone(id);
        String name = timeZone.getDisplayName();
        timeZone.setID("");
        String zone = timeZone.getDisplayName(false, TimeZone.SHORT);
        return String.format(Locale.getDefault(), FORMAT_ZONE, zone, name);
    }
}
