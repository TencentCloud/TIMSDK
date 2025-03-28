package com.tencent.cloud.tuikit.roomkit.view.main.mediasettings;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_AUDIO_CAPTURE_VOLUME_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_AUDIO_PLAY_VOLUME_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_AUDIO_VOLUME_EVALUATION_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_VIDEO_BITRATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_VIDEO_FPS_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_VIDEO_RESOLUTION_CHANGED;

import android.content.res.Configuration;
import android.util.Log;

import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceState;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;

import java.util.Map;

public class SettingViewModel
        implements ConferenceEventCenter.RoomEngineEventResponder, ConferenceEventCenter.RoomKitUIEventResponder {
    private static final String TAG = "SettingViewModel";

    private ConferenceState   mConferenceState;
    private MediaSettingPanel mSettingView;

    public SettingViewModel(MediaSettingPanel settingView) {
        mSettingView = settingView;
        mConferenceState = ConferenceController.sharedInstance().getConferenceState();

        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
        eventCenter.subscribeUIEvent(ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);

        eventCenter.subscribeEngine(LOCAL_VIDEO_FPS_CHANGED, this);
        eventCenter.subscribeEngine(LOCAL_VIDEO_RESOLUTION_CHANGED, this);
        eventCenter.subscribeEngine(LOCAL_VIDEO_BITRATE_CHANGED, this);
        eventCenter.subscribeEngine(LOCAL_AUDIO_CAPTURE_VOLUME_CHANGED, this);
        eventCenter.subscribeEngine(LOCAL_AUDIO_PLAY_VOLUME_CHANGED, this);
        eventCenter.subscribeEngine(LOCAL_AUDIO_VOLUME_EVALUATION_CHANGED, this);
    }


    public void destroy() {
        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
        eventCenter.unsubscribeUIEvent(ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);

        eventCenter.unsubscribeEngine(LOCAL_VIDEO_FPS_CHANGED, this);
        eventCenter.unsubscribeEngine(LOCAL_VIDEO_RESOLUTION_CHANGED, this);
        eventCenter.unsubscribeEngine(LOCAL_VIDEO_BITRATE_CHANGED, this);
        eventCenter.unsubscribeEngine(LOCAL_AUDIO_CAPTURE_VOLUME_CHANGED, this);
        eventCenter.unsubscribeEngine(LOCAL_AUDIO_PLAY_VOLUME_CHANGED, this);
        eventCenter.unsubscribeEngine(LOCAL_AUDIO_VOLUME_EVALUATION_CHANGED, this);
    }

    public void updateViewInitState() {
        mSettingView.onVideoFpsChanged(mConferenceState.videoModel.getFps());
        mSettingView.onVideoResolutionChanged(mConferenceState.videoModel.getCurrentResolutionName());

        mSettingView.onAudioCaptureVolumeChanged(mConferenceState.audioModel.getCaptureVolume());
        mSettingView.onAudioPlayVolumeChanged(mConferenceState.audioModel.getPlayVolume());
    }

    public void setAudioCaptureVolume(int volume) {
        ConferenceController.sharedInstance().setAudioCaptureVolume(volume);
    }

    public void setAudioPlayVolume(int volume) {
        ConferenceController.sharedInstance().setAudioPlayOutVolume(volume);
    }

    public void enableAudioEvaluation(boolean enable) {
        ConferenceController.sharedInstance().enableAudioVolumeEvaluation(enable);
    }

    public void enableFloatChat(boolean enable) {
        ConferenceController.sharedInstance().enableFloatChat(enable);
    }

    @Override
    public void onEngineEvent(ConferenceEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
            case LOCAL_VIDEO_FPS_CHANGED:
                mSettingView.onVideoFpsChanged(mConferenceState.videoModel.getFps());
                break;

            case LOCAL_VIDEO_RESOLUTION_CHANGED:
                mSettingView.onVideoResolutionChanged(mConferenceState.videoModel.getCurrentResolutionName());
                break;

            default:
                Log.w(TAG, "onEngineEvent un handle : " + event);
                break;
        }
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE.equals(key) && params != null) {
            Configuration configuration = (Configuration) params.get(ConferenceEventConstant.KEY_CONFIGURATION);
            mSettingView.changeConfiguration(configuration);
        }
    }
}
