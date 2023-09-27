package com.tencent.cloud.tuikit.roomkit.viewmodel;

import android.content.Context;
import android.content.res.Configuration;

import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.component.SettingView;

import java.util.Map;

public class SettingViewModel
        implements RoomEventCenter.RoomEngineEventResponder, RoomEventCenter.RoomKitUIEventResponder {

    private RoomStore   mRoomStore;
    private SettingView mSettingView;

    public SettingViewModel(SettingView settingView) {
        mSettingView = settingView;
        mRoomStore = RoomEngineManager.sharedInstance().getRoomStore();
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public void destroy() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public void setVideoBitrate(int bitrate) {
        if (bitrate == mRoomStore.videoModel.bitrate) {
            return;
        }
        RoomEngineManager.sharedInstance().setVideoBitrate(bitrate);
    }

    public void setVideoResolution(int resolution) {
        if (resolution == mRoomStore.videoModel.resolution) {
            return;
        }
        RoomEngineManager.sharedInstance().setVideoResolution(resolution);
    }

    public void setVideoFps(int fps) {
        if (fps == mRoomStore.videoModel.fps) {
            return;
        }
        RoomEngineManager.sharedInstance().setVideoFps(fps);
    }

    public void setVideoLocalMirror(boolean enable) {
        if (enable == mRoomStore.videoModel.isLocalMirror) {
            return;
        }
        RoomEngineManager.sharedInstance().enableVideoLocalMirror(enable);
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

    public void startFileDumping(String filePath) {
        RoomEngineManager.sharedInstance().startAudioRecording(filePath);
    }

    public void stopFileDumping() {
        RoomEngineManager.sharedInstance().stopAudioRecording();
    }

    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {

    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE.equals(key) && params != null) {
            Configuration configuration = (Configuration) params.get(RoomEventConstant.KEY_CONFIGURATION);
            mSettingView.changeConfiguration(configuration);
        }
    }
}
