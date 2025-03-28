package com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo;

import android.content.Context;
import android.view.LayoutInflater;
import android.widget.CompoundButton;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.SwitchCompat;

import com.tencent.cloud.tuikit.roomkit.R;
import com.trtc.tuikit.common.livedata.Observer;

public class SetConferenceDeviceView extends FrameLayout {
    private Context      mContext;
    private SwitchCompat mSwitchMuteAllAudio;
    private SwitchCompat mSwitchMuteAllVideo;

    private       ScheduleConferenceStateHolder        mStateHolder;
    private final Observer<SetConferenceDeviceUiState> mMediaObserver = this::updateView;

    public SetConferenceDeviceView(@NonNull Context context) {
        super(context);
        mContext = context;
        initView();
    }

    public void setStateHolder(ScheduleConferenceStateHolder stateHolder) {
        mStateHolder = stateHolder;
    }

    private void initView() {
        addView(LayoutInflater.from(mContext).inflate(R.layout.tuiroomkit_view_set_conference_device, this, false));
        mSwitchMuteAllAudio = findViewById(R.id.switch_mute_all_audio);
        mSwitchMuteAllVideo = findViewById(R.id.switch_mute_all_video);
        mSwitchMuteAllAudio.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                mStateHolder.updateMicrophoneDisableForAllUser(isChecked);
            }
        });
        mSwitchMuteAllVideo.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                mStateHolder.updateCameraDisableForAllUsers(isChecked);
            }
        });
    }

    public void disableSetDevice() {
        mSwitchMuteAllAudio.setClickable(false);
        mSwitchMuteAllVideo.setClickable(false);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        mStateHolder.observeMedia(mMediaObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mStateHolder.removeMediaObserver(mMediaObserver);
    }

    private void updateView(SetConferenceDeviceUiState uiState) {
        mSwitchMuteAllAudio.setChecked(uiState.isMicrophoneDisableForAllUser);
        mSwitchMuteAllVideo.setChecked(uiState.isCameraDisableForAllUser);
    }
}
