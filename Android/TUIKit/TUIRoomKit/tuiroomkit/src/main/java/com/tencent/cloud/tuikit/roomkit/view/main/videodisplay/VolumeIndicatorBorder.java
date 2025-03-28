package com.tencent.cloud.tuikit.roomkit.view.main.videodisplay;

import static com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant.VOLUME_CAN_HEARD_MIN_LIMIT;
import static com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant.VOLUME_INDICATOR_SHOW_TIME_MS;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.trtc.tuikit.common.livedata.Observer;

public class VolumeIndicatorBorder extends View {
    private String mUserId;

    private Handler  mMainHandler = new Handler(Looper.getMainLooper());
    private Runnable mHideRun     = this::hideBorder;

    private Observer<UserState.UserVolumeInfo> mVolumeObserver = this::onVolumeChanged;

    public VolumeIndicatorBorder(Context context) {
        this(context, null);
    }

    public VolumeIndicatorBorder(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        setBackground(ContextCompat.getDrawable(context, R.drawable.tuivideoseat_talk_bg_round));
    }

    public void onBindToRecyclerView(String userId) {
        setVisibility(INVISIBLE);
        mUserId = userId;
        ConferenceController.sharedInstance().getUserState().userVolumeInfo.observe(mVolumeObserver);
    }

    public void onRecycledByRecyclerView() {
        ConferenceController.sharedInstance().getUserState().userVolumeInfo.removeObserver(mVolumeObserver);
    }

    private void onVolumeChanged(UserState.UserVolumeInfo volumeInfo) {
        if (!TextUtils.equals(mUserId, volumeInfo.userId)) {
            return;
        }
        if (volumeInfo.volume < VOLUME_CAN_HEARD_MIN_LIMIT) {
            return;
        }
        setVisibility(VISIBLE);
        mMainHandler.removeCallbacks(mHideRun);
        mMainHandler.postDelayed(mHideRun, VOLUME_INDICATOR_SHOW_TIME_MS);
    }

    private void hideBorder() {
        setVisibility(INVISIBLE);
    }
}
