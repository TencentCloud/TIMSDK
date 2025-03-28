package com.tencent.cloud.tuikit.roomkit.view.main.mediasettings;

import android.content.Context;
import android.content.res.Configuration;
import android.view.View;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseBottomDialog;

import java.util.Map;

public class VideoResolutionChoicePanel extends BaseBottomDialog implements ConferenceEventCenter.RoomKitUIEventResponder {
    private TUIRoomDefine.VideoQuality[] mResolutionList = {
            TUIRoomDefine.VideoQuality.Q_360P, TUIRoomDefine.VideoQuality.Q_540P, TUIRoomDefine.VideoQuality.Q_720P,
            TUIRoomDefine.VideoQuality.Q_1080P};

    private int[] mLayoutResolutionList = {
            R.id.tuiroomkit_video_resolution_low, R.id.tuiroomkit_video_resolution_middle,
            R.id.tuiroomkit_video_resolution_high, R.id.tuiroomkit_video_resolution_super};

    private int[] mViewResolutionCheckedList = {
            R.id.tuiroomkit_video_resolution_low_checked, R.id.tuiroomkit_video_resolution_middle_checked,
            R.id.tuiroomkit_video_resolution_high_checked, R.id.tuiroomkit_video_resolution_super_checked};

    public VideoResolutionChoicePanel(@NonNull Context context) {
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
        return R.layout.tuiroomkit_dialog_video_resolution_choice;
    }

    @Override
    protected void initView() {
        for (int i = 0; i < mLayoutResolutionList.length; i++) {
            final TUIRoomDefine.VideoQuality resolution = mResolutionList[i];
            findViewById(mLayoutResolutionList[i]).setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (resolution != ConferenceController.sharedInstance().getConferenceState().videoModel.getResolution()) {
                        ConferenceController.sharedInstance().setVideoResolution(resolution);
                    }
                    dismiss();
                }
            });
        }

        TUIRoomDefine.VideoQuality curResolution =
                ConferenceController.sharedInstance().getConferenceState().videoModel.getResolution();
        for (int i = 0; i < mResolutionList.length; i++) {
            if (curResolution == mResolutionList[i]) {
                findViewById(mViewResolutionCheckedList[i]).setVisibility(View.VISIBLE);
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


