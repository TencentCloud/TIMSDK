package com.tencent.cloud.tuikit.roomkit.viewmodel;

import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_AUDIO_CAPTURE_VOLUME_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_AUDIO_PLAY_VOLUME_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_AUDIO_VOLUME_EVALUATION_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_VIDEO_BITRATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_VIDEO_FPS_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_VIDEO_RESOLUTION_CHANGED;

import android.content.res.Configuration;
import android.util.Log;

import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.MediaSettings.MediaSettingPanel;

import java.util.Map;

public class SettingViewModel
        implements RoomEventCenter.RoomEngineEventResponder, RoomEventCenter.RoomKitUIEventResponder {
    private static final String TAG = "SettingViewModel";

    private RoomStore         mRoomStore;
    private MediaSettingPanel mSettingView;

    public SettingViewModel(MediaSettingPanel settingView) {
        mSettingView = settingView;
        mRoomStore = RoomEngineManager.sharedInstance().getRoomStore();

        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);

        eventCenter.subscribeEngine(LOCAL_VIDEO_FPS_CHANGED, this);
        eventCenter.subscribeEngine(LOCAL_VIDEO_RESOLUTION_CHANGED, this);
        eventCenter.subscribeEngine(LOCAL_VIDEO_BITRATE_CHANGED, this);
        eventCenter.subscribeEngine(LOCAL_AUDIO_CAPTURE_VOLUME_CHANGED, this);
        eventCenter.subscribeEngine(LOCAL_AUDIO_PLAY_VOLUME_CHANGED, this);
        eventCenter.subscribeEngine(LOCAL_AUDIO_VOLUME_EVALUATION_CHANGED, this);
    }


    public void destroy() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);

        eventCenter.unsubscribeEngine(LOCAL_VIDEO_FPS_CHANGED, this);
        eventCenter.unsubscribeEngine(LOCAL_VIDEO_RESOLUTION_CHANGED, this);
        eventCenter.unsubscribeEngine(LOCAL_VIDEO_BITRATE_CHANGED, this);
        eventCenter.unsubscribeEngine(LOCAL_AUDIO_CAPTURE_VOLUME_CHANGED, this);
        eventCenter.unsubscribeEngine(LOCAL_AUDIO_PLAY_VOLUME_CHANGED, this);
        eventCenter.unsubscribeEngine(LOCAL_AUDIO_VOLUME_EVALUATION_CHANGED, this);
    }

    public void updateViewInitState() {
        mSettingView.onVideoFpsChanged(mRoomStore.videoModel.getFps());
        mSettingView.onVideoResolutionChanged(mRoomStore.videoModel.getCurrentResolutionName());

        mSettingView.onAudioCaptureVolumeChanged(mRoomStore.audioModel.getCaptureVolume());
        mSettingView.onAudioPlayVolumeChanged(mRoomStore.audioModel.getPlayVolume());
    }

    public void setAudioCaptureVolume(int volume) {
        RoomEngineManager.sharedInstance().setAudioCaptureVolume(volume);
    }

    public void setAudioPlayVolume(int volume) {
        RoomEngineManager.sharedInstance().setAudioPlayOutVolume(volume);
    }

    public void enableAudioEvaluation(boolean enable) {
        RoomEngineManager.sharedInstance().enableAudioVolumeEvaluation(enable);
    }

    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
            case LOCAL_VIDEO_FPS_CHANGED:
                mSettingView.onVideoFpsChanged(mRoomStore.videoModel.getFps());
                break;

            case LOCAL_VIDEO_RESOLUTION_CHANGED:
                mSettingView.onVideoResolutionChanged(mRoomStore.videoModel.getCurrentResolutionName());
                break;

            default:
                Log.w(TAG, "onEngineEvent un handle : " + event);
                break;
        }
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE.equals(key) && params != null) {
            Configuration configuration = (Configuration) params.get(RoomEventConstant.KEY_CONFIGURATION);
            mSettingView.changeConfiguration(configuration);
        }
    }
}
