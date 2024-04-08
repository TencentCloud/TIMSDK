package com.tencent.cloud.tuikit.roomkit.viewmodel;

import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.CAMERA_STREAM;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.SCREEN_STREAM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomConstant.USER_NOT_FOUND;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.USER_CAMERA_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.USER_MIC_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.USER_ROLE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.USER_SCREEN_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.USER_VOICE_VOLUME_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant.KEY_USER_POSITION;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.FloatWindow.VideoPlaying.RoomVideoFloatView;
import com.tencent.qcloud.tuicore.TUILogin;

import java.util.List;
import java.util.Map;

public class RoomVideoFloatViewModel implements RoomEventCenter.RoomEngineEventResponder {
    private static final String TAG = "RoomVideoFloatViewModel";

    private static final int VOLUME_CAN_HEARD_MIN_LIMIT = 10;

    private RoomVideoFloatView mRoomVideoFloatView;
    private TUIVideoView       mVideoView;

    private UserEntity mFloatUser;

    public RoomVideoFloatViewModel(RoomVideoFloatView roomVideoFloatView, TUIVideoView videoView) {
        mRoomVideoFloatView = roomVideoFloatView;
        mVideoView = videoView;

        initUserInfo();
        registerNotification();
    }

    public void destroy() {
        if (mFloatUser != null) {
            stopVideoPlay(mFloatUser);
        }
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

            case USER_MIC_STATE_CHANGED:
                handleEventMicStateChanged(params);
                break;

            case USER_CAMERA_STATE_CHANGED:
                handleEventCameraStateChanged(params);
                break;

            case USER_SCREEN_STATE_CHANGED:
                handleEventScreenStateChanged(params);
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
        if (params == null || mFloatUser == null) {
            return;
        }
        Map<String, Integer> map = (Map<String, Integer>) params.get(RoomEventConstant.KEY_VOLUME_MAP);
        for (Map.Entry<String, Integer> entry : map.entrySet()) {
            if (!TextUtils.equals(entry.getKey(), mFloatUser.getUserId())) {
                continue;
            }
            int volume = entry.getValue();
            if (volume > VOLUME_CAN_HEARD_MIN_LIMIT) {
                mRoomVideoFloatView.onNotifyAudioVolumeChanged(volume);
            }
            break;
        }
    }

    private void handleEventMicStateChanged(Map<String, Object> params) {
        if (params == null || mFloatUser == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        UserEntity micUser = RoomEngineManager.sharedInstance().getRoomStore().allUserList.get(position);
        if (!TextUtils.equals(micUser.getUserId(), mFloatUser.getUserId())) {
            return;
        }
        mRoomVideoFloatView.onNotifyAudioStreamStateChanged(micUser.isHasAudioStream());
    }

    private void handleEventCameraStateChanged(Map<String, Object> params) {
        if (isScreenSharing()) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        UserEntity cameraUser = RoomEngineManager.sharedInstance().getRoomStore().allUserList.get(position);
        if (!TextUtils.equals(cameraUser.getUserId(), mFloatUser.getUserId())) {
            return;
        }
        if (cameraUser.isHasVideoStream()) {
            startVideoPlay(mFloatUser);
        } else {
            stopVideoPlay(mFloatUser);
        }
    }

    private boolean isScreenSharing() {
        return mFloatUser != null && mFloatUser.isHasVideoStream() && mFloatUser.getVideoStreamType() == SCREEN_STREAM;
    }

    private void handleEventScreenStateChanged(Map<String, Object> params) {
        if (params == null || mFloatUser == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        UserEntity screenUser = RoomEngineManager.sharedInstance().getRoomStore().allUserList.get(position);
        if (screenUser.isHasVideoStream()) {
            if (mFloatUser.isHasVideoStream()) {
                stopVideoPlay(mFloatUser);
            }
            mFloatUser = screenUser;
            startVideoPlay(mFloatUser);
        } else {
            stopVideoPlay(mFloatUser);
            mFloatUser = findUserForFloatVideo();
            if (mFloatUser.isHasVideoStream()) {
                startVideoPlay(mFloatUser);
            }
        }
        mRoomVideoFloatView.onNotifyAudioStreamStateChanged(mFloatUser.isHasAudioStream());
        mRoomVideoFloatView.onNotifyUserInfoChanged(mFloatUser);
    }

    private void handleEventUserRoleChanged(Map<String, Object> params) {
        if (params == null || mFloatUser == null) {
            return;
        }
        TUIRoomDefine.Role role = (TUIRoomDefine.Role) params.get(RoomEventConstant.KEY_ROLE);
        if (role != TUIRoomDefine.Role.ROOM_OWNER) {
            return;
        }
        if (mFloatUser.isHasVideoStream() && mFloatUser.getVideoStreamType() == SCREEN_STREAM) {
            return;
        }
        if (mFloatUser.isHasVideoStream() && mFloatUser.getVideoStreamType() != SCREEN_STREAM) {
            stopVideoPlay(mFloatUser);
        }
        String userId = (String) params.get(RoomEventConstant.KEY_USER_ID);
        mFloatUser = findUser(userId, CAMERA_STREAM);
        if (mFloatUser.isHasVideoStream()) {
            startVideoPlay(mFloatUser);
        }
        mRoomVideoFloatView.onNotifyAudioStreamStateChanged(mFloatUser.isHasAudioStream());
        mRoomVideoFloatView.onNotifyUserInfoChanged(mFloatUser);
    }

    private void initUserInfo() {
        mFloatUser = findUserForFloatVideo();
        if (mFloatUser == null) {
            return;
        }
        mRoomVideoFloatView.onNotifyAudioStreamStateChanged(mFloatUser.isHasAudioStream());
        mRoomVideoFloatView.onNotifyVideoPlayStateChanged(mFloatUser.isHasVideoStream());
        mRoomVideoFloatView.onNotifyUserInfoChanged(mFloatUser);

        if (mFloatUser.isHasVideoStream()) {
            startVideoPlay(mFloatUser);
        }
    }

    private void registerNotification() {
        RoomEventCenter roomEventCenter = RoomEventCenter.getInstance();
        roomEventCenter.subscribeEngine(GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM, this);
        roomEventCenter.subscribeEngine(USER_ROLE_CHANGED, this);
        roomEventCenter.subscribeEngine(USER_CAMERA_STATE_CHANGED, this);
        roomEventCenter.subscribeEngine(USER_SCREEN_STATE_CHANGED, this);
        roomEventCenter.subscribeEngine(USER_MIC_STATE_CHANGED, this);
        roomEventCenter.subscribeEngine(USER_VOICE_VOLUME_CHANGED, this);
    }

    private void unRegisterNotification() {
        RoomEventCenter roomEventCenter = RoomEventCenter.getInstance();
        roomEventCenter.unsubscribeEngine(GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM, this);
        roomEventCenter.unsubscribeEngine(USER_ROLE_CHANGED, this);
        roomEventCenter.unsubscribeEngine(USER_CAMERA_STATE_CHANGED, this);
        roomEventCenter.unsubscribeEngine(USER_SCREEN_STATE_CHANGED, this);
        roomEventCenter.unsubscribeEngine(USER_MIC_STATE_CHANGED, this);
        roomEventCenter.unsubscribeEngine(USER_VOICE_VOLUME_CHANGED, this);
    }

    private void startVideoPlay(UserEntity userInfo) {
        if (TextUtils.equals(userInfo.getUserId(), TUILogin.getUserId())) {
            Log.d(TAG, "setLocalVideoView userId=" + userInfo.getUserId());
            RoomEngineManager.sharedInstance().setLocalVideoView(CAMERA_STREAM, mVideoView);
            mRoomVideoFloatView.onNotifyVideoPlayStateChanged(true);
            return;
        }

        RoomEngineManager.sharedInstance()
                .setRemoteVideoView(userInfo.getUserId(), userInfo.getVideoStreamType(), mVideoView);
        Log.d(TAG, "startPlayRemoteVideo userId=" + userInfo.getUserId() + " videoStreamType="
                + userInfo.getVideoStreamType());
        RoomEngineManager.sharedInstance()
                .startPlayRemoteVideo(userInfo.getUserId(), userInfo.getVideoStreamType(), null);
        mRoomVideoFloatView.onNotifyVideoPlayStateChanged(true);
    }

    private void stopVideoPlay(UserEntity userInfo) {
        mRoomVideoFloatView.onNotifyVideoPlayStateChanged(false);
        if (TextUtils.equals(userInfo.getUserId(), TUILogin.getUserId())) {
            RoomEngineManager.sharedInstance().setLocalVideoView(CAMERA_STREAM, null);
            return;
        }
        Log.d(TAG, "stopPlayRemoteVideo userId=" + userInfo.getUserId() + " videoStreamType="
                + userInfo.getVideoStreamType());
        RoomEngineManager.sharedInstance().stopPlayRemoteVideo(userInfo.getUserId(), userInfo.getVideoStreamType());
    }

    private UserEntity findUserForFloatVideo() {
        List<UserEntity> allUserList = RoomEngineManager.sharedInstance().getRoomStore().allUserList;
        if (allUserList.isEmpty()) {
            Log.e(TAG, "findUserForFloatVideo allUserList is empty");
            return null;
        }
        UserEntity roomOwner = null;
        for (UserEntity item : allUserList) {
            if (item.isHasVideoStream() && item.getVideoStreamType() == SCREEN_STREAM && !TextUtils.equals(
                    TUILogin.getUserId(), item.getUserId())) {
                return item;
            }
            if (TextUtils.equals(item.getUserId(), RoomEngineManager.sharedInstance().getRoomStore().roomInfo.ownerId)
                    && item.getVideoStreamType() != SCREEN_STREAM) {
                roomOwner = item;
            }
        }
        if (roomOwner == null) {
            Log.e(TAG, "findUserForFloatVideo roomOwner is null");
            return allUserList.get(0);
        }
        return roomOwner;
    }

    public UserEntity findUser(String userId, TUIRoomDefine.VideoStreamType type) {
        List<UserEntity> allUserList = RoomEngineManager.sharedInstance().getRoomStore().allUserList;
        for (UserEntity item : allUserList) {
            if (TextUtils.equals(userId, item.getUserId()) && item.getVideoStreamType() == type) {
                return item;
            }
        }
        return null;
    }
}
