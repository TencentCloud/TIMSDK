package com.tencent.cloud.tuikit.roomkit.view.page.widget.mediasettings;

import android.content.Context;
import android.view.View;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.component.BaseBottomDialog;

public class VideoFrameRateChoicePanel extends BaseBottomDialog {
    private int[] mFrameRateList = {15, 20};

    private int[] mLayoutFrameRateList = {R.id.tuiroomkit_video_frame_rate_15, R.id.tuiroomkit_video_frame_rate_20};

    private int[] mViewFrameRateCheckedList =
            {R.id.tuiroomkit_video_frame_rate_15_checked, R.id.tuiroomkit_video_frame_rate_20_checked};

    public VideoFrameRateChoicePanel(@NonNull Context context) {
        super(context);
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
                    if (frameRate != RoomEngineManager.sharedInstance().getRoomStore().videoModel.getFps()) {
                        RoomEngineManager.sharedInstance().setVideoFps(frameRate);
                    }
                    dismiss();
                }
            });
        }

        int curFrameRate = RoomEngineManager.sharedInstance().getRoomStore().videoModel.getFps();
        for (int i = 0; i < mFrameRateList.length; i++) {
            if (curFrameRate == mFrameRateList[i]) {
                findViewById(mViewFrameRateCheckedList[i]).setVisibility(View.VISIBLE);
                break;
            }
        }
    }
}


