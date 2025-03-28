package com.tencent.cloud.tuikit.roomkit.view.main.topnavigationbar;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.util.AttributeSet;

import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.qcloud.tuicore.util.DateTimeUtil;
import com.trtc.tuikit.common.livedata.Observer;

public class ConferenceDurationView extends androidx.appcompat.widget.AppCompatTextView {
    private static final int TIME_COUNT_INTERVAL_MS = 1000;

    private final Observer<Long> mObserver     = this::startTimeCount;
    private final Runnable       mTimeCountRun = this::runTimeCount;
    private final Handler        mMainHandler  = new Handler(Looper.getMainLooper());

    public ConferenceDurationView(Context context) {
        super(context);
    }

    public ConferenceDurationView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        ConferenceController.sharedInstance().getViewState().enterRoomTimeFromBoot.observe(mObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        ConferenceController.sharedInstance().getViewState().enterRoomTimeFromBoot.removeObserver(mObserver);
        stopTimeCount();
    }

    private void runTimeCount() {
        long enterRoomTime = ConferenceController.sharedInstance().getViewState().enterRoomTimeFromBoot.get();
        if (enterRoomTime == 0) {
            return;
        }
        int duration = (int) (SystemClock.elapsedRealtime() - enterRoomTime) / 1000;
        setText(DateTimeUtil.formatSecondsTo00(duration));
        mMainHandler.postDelayed(mTimeCountRun, TIME_COUNT_INTERVAL_MS);
    }

    private void startTimeCount(long enterRoomTime) {
        if (enterRoomTime == 0) {
            setText(DateTimeUtil.formatSecondsTo00(0));
            return;
        }
        mMainHandler.removeCallbacks(mTimeCountRun);
        mMainHandler.postDelayed(mTimeCountRun, TIME_COUNT_INTERVAL_MS);
    }

    private void stopTimeCount() {
        mMainHandler.removeCallbacks(mTimeCountRun);
    }
}
