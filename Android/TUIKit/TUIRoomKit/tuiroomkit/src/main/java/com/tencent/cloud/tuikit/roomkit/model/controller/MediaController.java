package com.tencent.cloud.tuikit.roomkit.model.controller;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceState;

public class MediaController extends Controller {
    private static final String TAG = "MediaController";

    public MediaController(ConferenceState conferenceState, TUIRoomEngine engine) {
        super(conferenceState, engine);
    }

    @Override
    public void destroy() {
    }

    public void setLocalVideoView(TUIVideoView videoView) {
        Log.d(TAG, "setLocalVideoView videoView=" + videoView);
        mRoomEngine.setLocalVideoView(videoView);
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
}
