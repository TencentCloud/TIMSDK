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
import java.util.List;

public class SetConferenceDurationView extends BottomSheetDialog implements View.OnClickListener {
    private static final int                                  mMaxMinute                 = 60;
    private static final int                                  mMaxHour                   = 24;
    private static final int                                  MINUTE_INTERVAL            = 5;
    public static final  int                                  MILLISECONDS_IN_ONE_HOUR   = 60 * 60 * 1000;
    public static final  int                                  MILLISECONDS_IN_ONE_MINUTE = 60 * 1000;
    private              Context                              mContext;
    private              WheelPicker                          mWpSelectHour;
    private              WheelPicker                          mWpSelectMinute;
    private              LinearLayout                         mLayoutDurationConfirm;
    private              LinearLayout                         mLayoutDurationClose;
    private              int                                  mHourValue                 = 0;
    private              int                                  mMinuteValue               = 0;
    private              List<String>                         mHourStringList            = new ArrayList<>();
    private              List<String>                         mMinuteStringList          = new ArrayList<>();
    private              ScheduleConferenceStateHolder        mStateHolder;
    private final        Observer<SetConferenceDetailUiState> mDurationObserver          = this::updateView;

    public void setStateHolder(ScheduleConferenceStateHolder stateHolder) {
        this.mStateHolder = stateHolder;
    }

    public SetConferenceDurationView(@NonNull Context context) {
        super(context, R.style.TUIRoomDialogFragmentTheme);
        mContext = context;
        setContentView(R.layout.tuiroomkit_view_duration_select);
        initData();
        initView();
    }

    private void initData() {
        for (int position = 0; position < mMaxMinute; position++) {
            if (position < mMaxHour) {
                mHourStringList.add(mContext.getString(R.string.tuiroomkit_hour_text, position));
            }
            if (position % MINUTE_INTERVAL == 0) {
                mMinuteStringList.add(mContext.getString(R.string.tuiroomkit_minute_text, position));
            }
        }
    }

    private void initView() {
        mLayoutDurationClose = findViewById(R.id.ll_duration_close);
        mLayoutDurationClose.setOnClickListener(this);
        mLayoutDurationConfirm = findViewById(R.id.ll_duration_confirm);
        mLayoutDurationConfirm.setOnClickListener(this);

        mWpSelectHour = findViewById(R.id.np_select_hour);
        mWpSelectHour.setData(mHourStringList);

        mWpSelectMinute = findViewById(R.id.np_select_minute);
        mWpSelectMinute.setData(mMinuteStringList);
        mWpSelectHour.setOnItemSelectedListener(new WheelPicker.OnItemSelectedListener() {
            @Override
            public void onItemSelected(WheelPicker wheelPicker, Object o, int position) {
                if (position == 0 && mWpSelectMinute.getCurrentItemPosition() < 3) {
                    wheelPicker.setSelectedItemPosition(0);
                    mWpSelectMinute.setSelectedItemPosition(3);
                    RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_minimum_duration_is_fifteen_minutes));
                }
            }
        });
        mWpSelectMinute.setOnItemSelectedListener(new WheelPicker.OnItemSelectedListener() {
            @Override
            public void onItemSelected(WheelPicker wheelPicker, Object o, int position) {
                if (position < 3 && mWpSelectHour.getCurrentItemPosition() == 0) {
                    mWpSelectHour.setSelectedItemPosition(0);
                    wheelPicker.setSelectedItemPosition(3);
                    RoomToast.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_minimum_duration_is_fifteen_minutes));
                }
            }
        });
    }

    @Override
    public void onClick(View view) {
        if (view.getId() == R.id.ll_duration_close) {
            dismiss();
        } else if (view.getId() == R.id.ll_duration_confirm) {
            mMinuteValue = mWpSelectMinute.getCurrentItemPosition() * MINUTE_INTERVAL;
            mHourValue = mWpSelectHour.getCurrentItemPosition();
            int ms = mHourValue * MILLISECONDS_IN_ONE_HOUR + mMinuteValue * MILLISECONDS_IN_ONE_MINUTE;
            mStateHolder.updateScheduleDuration(ms);
            dismiss();
        }
    }

    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
        mStateHolder.observeDuration(mDurationObserver);
    }

    @Override
    public void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mStateHolder.removeDurationObserve(mDurationObserver);
    }

    private void updateView(SetConferenceDetailUiState uiState) {
        int duration = uiState.scheduleDuration;
        mHourValue = duration / MILLISECONDS_IN_ONE_HOUR;
        mMinuteValue = duration % MILLISECONDS_IN_ONE_HOUR / MILLISECONDS_IN_ONE_MINUTE;
        mWpSelectHour.setSelectedItemPosition(mHourValue);
        mWpSelectMinute.setSelectedItemPosition(mMinuteValue / MINUTE_INTERVAL);
    }
}
