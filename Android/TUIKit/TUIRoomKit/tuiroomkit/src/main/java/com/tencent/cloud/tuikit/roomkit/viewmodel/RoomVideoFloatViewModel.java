package com.tencent.cloud.tuikit.roomkit.viewmodel;

import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.USER_AUDIO_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.USER_ROLE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.USER_VIDEO_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.USER_VOICE_VOLUME_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.EXIT_FLOAT_WINDOW;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.component.RoomVideoFloatView;
import com.tencent.qcloud.tuicore.TUILogin;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RoomVideoFloatViewModel implements RoomEventCenter.RoomEngineEventResponder {
    private static final String TAG = "RoomVideoFloatViewModel";

    private static final int VOLUME_CAN_HEARD_MIN_LIMIT = 10;

    private Context mAppContext;

    private RoomVideoFloatView mRoomVideoFloatView;
    private TUIVideoView       mVideoView;

    private TUIRoomEngine mRoomEngine;
    private RoomStore     mRoomStore;

    private TUIRoomDefine.UserInfo mFloatUserInfo;

    public RoomVideoFloatViewModel(Context context, RoomVideoFloatView roomVideoFloatView, TUIVideoView videoView) {
        mAppContext = context.getApplicationContext();
        mRoomVideoFloatView = roomVideoFloatView;
        mVideoView = videoView;

        mRoomEngine = RoomEngineManager.sharedInstance(mAppContext).getRoomEngine();
        mRoomStore = RoomEngineManager.sharedInstance(mAppContext).getRoomStore();

        initUserInfo();
        registerNotification();
    }

    public void destroy() {
        TUIRoomDefine.VideoStreamType videoStreamType =
                mFloatUserInfo.hasScreenStream ? TUIRoomDefine.VideoStreamType.SCREEN_STREAM :
                        TUIRoomDefine.VideoStreamType.CAMERA_STREAM;
        stopVideoPlay(mFloatUserInfo, videoStreamType);
        mRoomVideoFloatView = null;
        mVideoView = null;
        unRegisterNotification();
    }

    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
            case GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM:
                initUserInfo();
                break;

            case USER_VOICE_VOLUME_CHANGED:
                handleEventVoiceVolumeChanged(params);
                break;

            case USER_AUDIO_STATE_CHANGED:
                handleEventAudioStateChanged(params);
                break;

            case USER_VIDEO_STATE_CHANGED:
                handleEventVideoStateChanged(params);
                break;

            case USER_ROLE_CHANGED:
                handleEventUserRoleChanged(params);
                break;

            default:
                Log.w(TAG, "un handle event : " + event);
                break;
        }
    }

    private void handleEventVoiceVolumeChanged(Map<String, Object> params) {
        if (params == null || mFloatUserInfo == null) {
            return;
        }
        Map<String, Integer> map = (Map<String, Integer>) params.get(RoomEventConstant.KEY_VOLUME_MAP);
        for (Map.Entry<String, Integer> entry : map.entrySet()) {
            if (!TextUtils.equals(entry.getKey(), mFloatUserInfo.userId)) {
                continue;
            }
            int volume = entry.getValue();
            if (volume > VOLUME_CAN_HEARD_MIN_LIMIT) {
                mRoomVideoFloatView.onNotifyAudioVolumeChanged(volume);
            }
            break;
        }
    }

    private void handleEventAudioStateChanged(Map<String, Object> params) {
        if (params == null || mFloatUserInfo == null) {
            return;
        }
        String userId = (String) params.get(RoomEventConstant.KEY_USER_ID);
        boolean hasAudio = (boolean) params.get(RoomEventConstant.KEY_HAS_AUDIO);
        if (TextUtils.equals(userId, mFloatUserInfo.userId)) {
            mRoomVideoFloatView.onNotifyAudioStreamStateChanged(hasAudio);
        }
    }

    private void handleEventVideoStateChanged(Map<String, Object> params) {
        if (params == null || mFloatUserInfo == null) {
            return;
        }
        String userId = (String) params.get(RoomEventConstant.KEY_USER_ID);
        boolean hasVideo = (boolean) params.get(RoomEventConstant.KEY_HAS_VIDEO);
        TUIRoomDefine.VideoStreamType streamType =
                (TUIRoomDefine.VideoStreamType) params.get(RoomEventConstant.KEY_STREAM_TYPE);
        if (streamType == TUIRoomDefine.VideoStreamType.SCREEN_STREAM) {
            handleScreenShareStateChanged(userId, hasVideo);
        } else {
            handleCameraStateChanged(userId, hasVideo);
        }
    }

    private void handleEventUserRoleChanged(Map<String, Object> params) {
        if (params == null || mFloatUserInfo == null) {
            return;
        }
        TUIRoomDefine.Role role = (TUIRoomDefine.Role) params.get(RoomEventConstant.KEY_ROLE);
        if (role != TUIRoomDefine.Role.ROOM_OWNER) {
            return;
        }
        if (mFloatUserInfo.hasScreenStream) {
            return;
        }
        if (mFloatUserInfo.hasVideoStream) {
            stopVideoPlay(mFloatUserInfo, TUIRoomDefine.VideoStreamType.CAMERA_STREAM);
        }
        String userId = (String) params.get(RoomEventConstant.KEY_USER_ID);
        mFloatUserInfo = findUserInfoByUserId(userId);
        if (mFloatUserInfo.hasVideoStream) {
            startVideoPlay(mFloatUserInfo, TUIRoomDefine.VideoStreamType.CAMERA_STREAM);
        }
        mRoomVideoFloatView.onNotifyAudioStreamStateChanged(mFloatUserInfo.hasAudioStream);
        mRoomVideoFloatView.onNotifyUserInfoChanged(mFloatUserInfo);
    }

    private void handleScreenShareStateChanged(String userId, boolean hasVideo) {
        if (hasVideo) {
            if (mFloatUserInfo.hasVideoStream) {
                stopVideoPlay(mFloatUserInfo, TUIRoomDefine.VideoStreamType.CAMERA_STREAM);
            }
            mFloatUserInfo = findUserInfoByUserId(userId);
            startVideoPlay(mFloatUserInfo, TUIRoomDefine.VideoStreamType.SCREEN_STREAM);
        } else {
            stopVideoPlay(mFloatUserInfo, TUIRoomDefine.VideoStreamType.SCREEN_STREAM);
            mFloatUserInfo = findUserForFloatVideo();
            if (mFloatUserInfo.hasVideoStream) {
                startVideoPlay(mFloatUserInfo, TUIRoomDefine.VideoStreamType.CAMERA_STREAM);
            }
        }
        mRoomVideoFloatView.onNotifyAudioStreamStateChanged(mFloatUserInfo.hasAudioStream);
        mRoomVideoFloatView.onNotifyUserInfoChanged(mFloatUserInfo);
    }

    private void handleCameraStateChanged(String userId, boolean hasVideo) {
        if (!TextUtils.equals(userId, mFloatUserInfo.userId) || mFloatUserInfo.hasScreenStream) {
            return;
        }
        if (hasVideo) {
            startVideoPlay(mFloatUserInfo, TUIRoomDefine.VideoStreamType.CAMERA_STREAM);
        } else {
            stopVideoPlay(mFloatUserInfo, TUIRoomDefine.VideoStreamType.CAMERA_STREAM);
        }
    }

    private void initUserInfo() {
        mFloatUserInfo = findUserForFloatVideo();
        if (mFloatUserInfo == null) {
            return;
        }
        mRoomVideoFloatView.onNotifyAudioStreamStateChanged(mFloatUserInfo.hasAudioStream);
        mRoomVideoFloatView.onNotifyVideoPlayStateChanged(
                mFloatUserInfo.hasVideoStream || mFloatUserInfo.hasScreenStream);
        mRoomVideoFloatView.onNotifyUserInfoChanged(mFloatUserInfo);

        TUIRoomDefine.VideoStreamType videoStreamType =
                mFloatUserInfo.hasScreenStream ? TUIRoomDefine.VideoStreamType.SCREEN_STREAM :
                        TUIRoomDefine.VideoStreamType.CAMERA_STREAM;
        if (mFloatUserInfo.hasScreenStream || mFloatUserInfo.hasVideoStream) {
            startVideoPlay(mFloatUserInfo, videoStreamType);
        }
    }

    private void registerNotification() {
        RoomEventCenter roomEventCenter = RoomEventCenter.getInstance();
        roomEventCenter.subscribeEngine(GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM, this);
        roomEventCenter.subscribeEngine(USER_ROLE_CHANGED, this);
        roomEventCenter.subscribeEngine(USER_VIDEO_STATE_CHANGED, this);
        roomEventCenter.subscribeEngine(USER_AUDIO_STATE_CHANGED, this);
        roomEventCenter.subscribeEngine(USER_VOICE_VOLUME_CHANGED, this);
    }

    private void unRegisterNotification() {
        RoomEventCenter roomEventCenter = RoomEventCenter.getInstance();
        roomEventCenter.unsubscribeEngine(GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM, this);
        roomEventCenter.unsubscribeEngine(USER_ROLE_CHANGED, this);
        roomEventCenter.unsubscribeEngine(USER_VIDEO_STATE_CHANGED, this);
        roomEventCenter.unsubscribeEngine(USER_AUDIO_STATE_CHANGED, this);
        roomEventCenter.unsubscribeEngine(USER_VOICE_VOLUME_CHANGED, this);
    }

    private void startVideoPlay(TUIRoomDefine.UserInfo userInfo, TUIRoomDefine.VideoStreamType videoStreamType) {
        if (TextUtils.equals(userInfo.userId, TUILogin.getUserId())) {
            Log.d(TAG, "setLocalVideoView userId=" + userInfo.userId);
            mRoomEngine.setLocalVideoView(TUIRoomDefine.VideoStreamType.CAMERA_STREAM, mVideoView);
            mRoomVideoFloatView.onNotifyVideoPlayStateChanged(true);
            return;
        }

        mRoomEngine.setRemoteVideoView(userInfo.userId, videoStreamType, mVideoView);
        Log.d(TAG, "startPlayRemoteVideo userId=" + userInfo.userId + " videoStreamType=" + videoStreamType);
        mRoomEngine.startPlayRemoteVideo(userInfo.userId, videoStreamType, new TUIRoomDefine.PlayCallback() {
            @Override
            public void onPlaying(String s) {
                Log.d(TAG, "startPlayRemoteVideo onPlaying s=" + s);
            }

            @Override
            public void onLoading(String s) {
            }

            @Override
            public void onPlayError(String s, TUICommonDefine.Error error, String s1) {
                Log.e(TAG, "startPlayRemoteVideo onPlayError s=" + s + " error=" + error + " s1=" + s1);
            }
        });
        mRoomVideoFloatView.onNotifyVideoPlayStateChanged(true);
    }

    private void stopVideoPlay(TUIRoomDefine.UserInfo userInfo, TUIRoomDefine.VideoStreamType videoStreamType) {
        mRoomVideoFloatView.onNotifyVideoPlayStateChanged(false);
        if (TextUtils.equals(userInfo.userId, TUILogin.getUserId())) {
            mRoomEngine.setLocalVideoView(TUIRoomDefine.VideoStreamType.CAMERA_STREAM, null);
            return;
        }
        Log.d(TAG, "stopPlayRemoteVideo userId=" + userInfo.userId + " videoStreamType=" + videoStreamType);
        mRoomEngine.stopPlayRemoteVideo(userInfo.userId, videoStreamType);
    }

    private TUIRoomDefine.UserInfo findUserForFloatVideo() {
        List<TUIRoomDefine.UserInfo> allUserList =
                RoomEngineManager.sharedInstance(mAppContext).getRoomStore().allUserList;
        if (allUserList.isEmpty()) {
            Log.e(TAG, "findUserForFloatVideo allUserList is empty");
            return null;
        }
        TUIRoomDefine.UserInfo roomOwner = null;
        for (TUIRoomDefine.UserInfo item : allUserList) {
            if (item.hasScreenStream) {
                return item;
            }
            if (item.userRole == TUIRoomDefine.Role.ROOM_OWNER) {
                roomOwner = item;
            }
        }
        if (roomOwner == null) {
            Log.e(TAG, "findUserForFloatVideo roomOwner is null");
            return allUserList.get(0);
        }
        return roomOwner;
    }

    public TUIRoomDefine.UserInfo findUserInfoByUserId(String userId) {
        List<TUIRoomDefine.UserInfo> allUserList =
                RoomEngineManager.sharedInstance(mAppContext).getRoomStore().allUserList;
        for (TUIRoomDefine.UserInfo item : allUserList) {
            if (TextUtils.equals(userId, item.userId)) {
                return item;
            }
        }
        return null;
    }
}
