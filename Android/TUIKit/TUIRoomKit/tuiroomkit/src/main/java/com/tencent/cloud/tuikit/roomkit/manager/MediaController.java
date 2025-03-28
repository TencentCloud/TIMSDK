package com.tencent.cloud.tuikit.roomkit.manager;

import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.engine.extension.TUIRoomDeviceManager;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceState;

public class MediaController extends Controller {
    private static final String TAG = "MediaController";

    public MediaController(ConferenceState conferenceState, TUIRoomEngine engine) {
        super(conferenceState, engine);
    }

    @Override
    public void destroy() {
    }

    public void startPlayRemoteVideo(String userId, TUIRoomDefine.VideoStreamType videoStreamType,
                                     TUIVideoView videoView) {
        mRoomEngine.setRemoteVideoView(userId, videoStreamType, videoView);
        Log.d(TAG, "startPlayRemoteVideo userId=" + userId + " videoStreamType=" + videoStreamType + " videoView="
                + videoView);
        mRoomEngine.startPlayRemoteVideo(userId, videoStreamType, null);
    }

    public void stopPlayRemoteVideo(String userId, TUIRoomDefine.VideoStreamType videoStreamType) {
        Log.d(TAG, "stopPlayRemoteVideo userId=" + userId + " videoStreamType=" + videoStreamType);
        mRoomEngine.stopPlayRemoteVideo(userId, videoStreamType);
    }

    public void switchAudioRoute() {
        boolean isOpenSpeaker = !mMediaState.isSpeakerOpened.get();
        setAudioRoute(isOpenSpeaker);
    }

    public void setAudioRoute(boolean isOpenSpeaker) {
        mRoomEngine.getMediaDeviceManager().setAudioRoute(
                isOpenSpeaker ? TUIRoomDeviceManager.AudioRoute.SPEAKERPHONE :
                        TUIRoomDeviceManager.AudioRoute.EARPIECE);
        mConferenceState.mediaState.isSpeakerOpened.set(isOpenSpeaker);
    }

    public void switchCamera() {
        boolean isFrontCamera = !mMediaState.isFrontCamera.get();
        mRoomEngine.getMediaDeviceManager().switchCamera(isFrontCamera);
        mMediaState.isFrontCamera.set(isFrontCamera);
    }
}
