package com.tencent.cloud.tuikit.roomkit.view.main.mediasettings;

import android.content.Context;
import android.content.res.Configuration;
import android.view.View;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseBottomDialog;

import java.util.Map;

public class VideoFrameRateChoicePanel extends BaseBottomDialog implements ConferenceEventCenter.RoomKitUIEventResponder {
    private int[] mFrameRateList = {15, 20};

    private int[] mLayoutFrameRateList = {R.id.tuiroomkit_video_frame_rate_15, R.id.tuiroomkit_video_frame_rate_20};

    private int[] mViewFrameRateCheckedList =
            {R.id.tuiroomkit_video_frame_rate_15_checked, R.id.tuiroomkit_video_frame_rate_20_checked};

    public VideoFrameRateChoicePanel(@NonNull Context context) {
        super(context);
        ConferenceEventCenter.getInstance().subscribeUIEvent(ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        ConferenceEventCenter.getInstance().unsubscribeUIEvent(ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_dialog_video_frame_rate_choice;
    }

    @Override
    protected void initView() {
        for (int i = 0; i < mLayoutFrameRateList.length; i++) {
            final int frameRate = mFrameRateList[i];
            findViewById(mLayoutFrameRateList[i]).setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (frameRate != ConferenceController.sharedInstance().getConferenceState().videoModel.getFps()) {
                        ConferenceController.sharedInstance().setVideoFps(frameRate);
                    }
                    dismiss();
                }
            });
        }

        int curFrameRate = ConferenceController.sharedInstance().getConferenceState().videoModel.getFps();
        for (int i = 0; i < mFrameRateList.length; i++) {
            if (curFrameRate == mFrameRateList[i]) {
                findViewById(mViewFrameRateCheckedList[i]).setVisibility(View.VISIBLE);
                break;
            }
        }
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE.equals(key) && params != null) {
            Configuration configuration = (Configuration) params.get(ConferenceEventConstant.KEY_CONFIGURATION);
            changeConfiguration(configuration);
        }
    }
}


