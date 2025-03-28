package com.tencent.cloud.tuikit.roomkit.view.main.mediasettings;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.DISMISS_MEDIA_SETTING_PANEL;

import android.content.Context;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.SwitchCompat;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.MetricsStats;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseBottomDialog;

public class MediaSettingPanel extends BaseBottomDialog {

    private ConstraintLayout mClVideoResolution;
    private TextView         mTvVideoResolution;

    private ConstraintLayout mClQualityCheck;
    private SwitchCompat     mSwitchEnableFloatChat;

    private ConstraintLayout mClVideoFps;
    private TextView         mTvVideoFps;

    private SeekBar  mPbAudioCaptureVolume;
    private TextView mTvAudioCaptureVolume;

    private SeekBar      mPbAudioPlayVolume;
    private TextView     mTvAudioPlayVolume;
    private SwitchCompat mSwitchAudioVolumeEvaluation;

    private Context mContext;

    private SettingViewModel mViewModel;

    public MediaSettingPanel(@NonNull Context context) {
        super(context);
        mContext = context;
        mViewModel = new SettingViewModel(this);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        ConferenceEventCenter.getInstance().notifyUIEvent(DISMISS_MEDIA_SETTING_PANEL, null);
        mViewModel.destroy();
    }

    public void onVideoFpsChanged(int fps) {
        mTvVideoFps.setText(fps + "");
    }

    public void onVideoResolutionChanged(String resolution) {
        mTvVideoResolution.setText(resolution);
    }

    public void onAudioCaptureVolumeChanged(int volume) {
        mPbAudioCaptureVolume.setProgress(volume);
        mTvAudioCaptureVolume.setText(volume + "");
    }

    public void onAudioPlayVolumeChanged(int volume) {
        mPbAudioPlayVolume.setProgress(volume);
        mTvAudioPlayVolume.setText(volume + "");
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_panel_setting;
    }

    @Override
    protected void initView() {
        initVideoResolutionView();
        initVideoFpsView();

        initAudioCaptureVolumeView();
        initAudioPlayVolumeView();
        initAudioVolumeEvaluationView();
        initQualityInfoView();

        mViewModel.updateViewInitState();
    }

    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
        MetricsStats.submit(MetricsStats.T_METRICS_SETTINGS_PANEL_SHOW);
    }

    private void initVideoResolutionView() {
        mClVideoResolution = findViewById(R.id.tuiroomkit_settings_video_resolution);
        mTvVideoResolution = findViewById(R.id.tuiroomkit_tv_settings_video_resolution);
        mClVideoResolution.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                VideoResolutionChoicePanel videoResolutionChoicePanel = new VideoResolutionChoicePanel(mContext);
                videoResolutionChoicePanel.show();
            }
        });
    }

    private void initQualityInfoView() {
        mClQualityCheck = findViewById(R.id.tuiroomkit_quality_check);
        mSwitchEnableFloatChat = findViewById(R.id.tuiroomkit_enable_float_chat);
        mClQualityCheck.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                QualityInfoPanel qualityInfoPanel = new QualityInfoPanel(mContext);
                qualityInfoPanel.show();
            }
        });
        mSwitchEnableFloatChat.setChecked(ConferenceController.sharedInstance().getConferenceState().getEnableFloatChat());
        mSwitchEnableFloatChat.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                mViewModel.enableFloatChat(isChecked);
            }
        });
    }


    private void initVideoFpsView() {
        mClVideoFps = findViewById(R.id.tuiroomkit_settings_video_fps);
        mTvVideoFps = findViewById(R.id.tuiroomkit_tv_settings_video_fps);
        mClVideoFps.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                VideoFrameRateChoicePanel videoFrameRateChoicePanel = new VideoFrameRateChoicePanel(mContext);
                videoFrameRateChoicePanel.show();
            }
        });
    }

    private void initAudioCaptureVolumeView() {
        mPbAudioCaptureVolume = findViewById(R.id.tuiroomkit_settings_audio_capture_volume);
        mTvAudioCaptureVolume = findViewById(R.id.tuiroomkit_tv_audio_capture_volume);
        mPbAudioCaptureVolume.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            int captureProgress;

            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                mTvAudioCaptureVolume.setText(progress + "");
                captureProgress = progress;
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                mViewModel.setAudioCaptureVolume(captureProgress);
            }
        });
    }

    private void initAudioPlayVolumeView() {
        mPbAudioPlayVolume = findViewById(R.id.tuiroomkit_settings_audio_play_volume);
        mTvAudioPlayVolume = findViewById(R.id.tuiroomkit_tv_audio_play_volume);
        mPbAudioPlayVolume.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            int playProgress;

            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                mTvAudioPlayVolume.setText(progress + "");
                playProgress = progress;
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                mViewModel.setAudioPlayVolume(playProgress);
            }
        });
    }

    private void initAudioVolumeEvaluationView() {
        mSwitchAudioVolumeEvaluation = findViewById(R.id.tuiroomkit_switch_audio_volume_evaluation);
        mSwitchAudioVolumeEvaluation.setChecked(
                ConferenceController.sharedInstance().getConferenceState().audioModel.isEnableVolumeEvaluation());
        mSwitchAudioVolumeEvaluation.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                mViewModel.enableAudioEvaluation(isChecked);
            }
        });
    }
}


