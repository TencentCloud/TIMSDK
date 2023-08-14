package com.tencent.cloud.tuikit.roomkit.viewmodel;

import android.content.Context;
import android.content.res.Configuration;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.utils.DrawOverlaysPermissionUtil;
import com.tencent.cloud.tuikit.roomkit.view.component.SettingView;
import com.tencent.trtc.TRTCCloudDef;

import java.util.List;
import java.util.Map;

public class SettingViewModel implements RoomEventCenter.RoomEngineEventResponder,
        RoomEventCenter.RoomKitUIEventResponder {

    private RoomStore     mRoomStore;
    private TUIRoomEngine mRoomEngine;
    private SettingView   mSettingView;

    public SettingViewModel(Context context, SettingView settingView) {
        mSettingView = settingView;
        RoomEngineManager engineManager = RoomEngineManager.sharedInstance(context);
        mRoomEngine = engineManager.getRoomEngine();
        mRoomStore = engineManager.getRoomStore();
        mSettingView.enableShareButton(TUIRoomDefine.SpeechMode.FREE_TO_SPEAK.equals(mRoomStore.roomInfo.speechMode)
                || mRoomStore.userModel.isOnSeat);
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_VIDEO_STATE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.SEAT_LIST_CHANGED, this);

        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public void destroy() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_VIDEO_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.SEAT_LIST_CHANGED, this);

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

    public void startScreenShare() {
        if (!DrawOverlaysPermissionUtil.isGrantedDrawOverlays()) {
            DrawOverlaysPermissionUtil.requestDrawOverlays();
            return;
        }
        RoomEngineManager.sharedInstance().startScreenCapture();
    }

    public void stopScreenShare() {
        RoomEngineManager.sharedInstance().stopScreenCapture();
    }

    public void enableAudioEvaluation(boolean enable) {
        RoomEngineManager.sharedInstance().enableAudioVolumeEvaluation(enable);
    }

    public void startFileDumping(String filePath) {
        TRTCCloudDef.TRTCAudioRecordingParams params = new TRTCCloudDef.TRTCAudioRecordingParams();
        params.filePath = filePath;
        mRoomEngine.getTRTCCloud().startAudioRecording(params);
    }

    public void stopFileDumping() {
        mRoomEngine.getTRTCCloud().stopAudioRecording();
    }

    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        if (RoomEventCenter.RoomEngineEvent.USER_VIDEO_STATE_CHANGED.equals(event)) {
            onUserVideoStateChanged(params);
        }
        switch (event) {
            case USER_VIDEO_STATE_CHANGED:
                onUserVideoStateChanged(params);
                break;
            case SEAT_LIST_CHANGED:
                onSeatListChanged(params);
                break;
            default:
                break;
        }
    }

    private void onUserVideoStateChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }

        TUIRoomDefine.VideoStreamType videoStreamType = (TUIRoomDefine.VideoStreamType)
                params.get(RoomEventConstant.KEY_STREAM_TYPE);

        if (TUIRoomDefine.VideoStreamType.SCREEN_STREAM.equals(videoStreamType)) {
            boolean available = (boolean) params.get(RoomEventConstant.KEY_HAS_VIDEO);
            mSettingView.enableShareButton(!available);
        }
    }

    private void onSeatListChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        List<TUIRoomDefine.SeatInfo> userSeatedList = (List<TUIRoomDefine.SeatInfo>)
                params.get(RoomEventConstant.KEY_SEATED_LIST);

        if (userSeatedList != null && !userSeatedList.isEmpty()) {
            for (TUIRoomDefine.SeatInfo info : userSeatedList) {
                if (info.userId.equals(mRoomStore.userModel.userId)) {
                    mSettingView.enableShareButton(true);
                }
            }
        }

        List<TUIRoomDefine.SeatInfo> userLeftList = (List<TUIRoomDefine.SeatInfo>)
                params.get(RoomEventConstant.KEY_LEFT_LIST);
        if (userLeftList != null && !userLeftList.isEmpty()) {
            for (TUIRoomDefine.SeatInfo info : userLeftList) {
                if (info.userId.equals(mRoomStore.userModel.userId)) {
                    mSettingView.enableShareButton(false);
                }
            }
        }
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE.equals(key)
                && params != null) {
            Configuration configuration = (Configuration) params.get(RoomEventConstant.KEY_CONFIGURATION);
            mSettingView.changeConfiguration(configuration);
        }
    }
}
