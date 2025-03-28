package com.tencent.cloud.tuikit.roomkit.view.main.floatwindow.videoplaying;

import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.CAMERA_STREAM;
import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.SCREEN_STREAM;
import static com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant.USER_NOT_FOUND;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.KICKED_OFF_LINE;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.KICKED_OUT_OF_ROOM;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.ROOM_DISMISSED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.USER_CAMERA_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.USER_MIC_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.USER_ROLE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.USER_SCREEN_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_USER_POSITION;

import android.os.SystemClock;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.state.ViewState;
import com.tencent.cloud.tuikit.roomkit.state.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.qcloud.tuicore.TUILogin;
import com.trtc.tuikit.common.livedata.LiveListObserver;
import com.trtc.tuikit.common.livedata.Observer;
import com.trtc.tuikit.common.system.ContextProvider;

import java.util.List;
import java.util.Map;

public class RoomVideoFloatViewModel implements ConferenceEventCenter.RoomEngineEventResponder {
    private static final String TAG = "RoomVideoFloatViewModel";

    private static final int VOLUME_CAN_HEARD_MIN_LIMIT = 10;
    private static final int VIDEO_SWITCH_INTERVAL_MS   = 5 * 1000;

    private long mLastSwitchTime = 0L;

    private RoomVideoFloatView mRoomVideoFloatView;
    private TUIVideoView       mVideoView;

    private       UserEntity                           mFloatUser;
    private final Observer<Map<String, Integer>>       mVolumeObserver         = this::handleVolumeChanged;
    private final Observer<Boolean>                    mIsPictureInPictureMode = this::onPictureInPictureModeChanged;
    private final LiveListObserver<UserState.UserInfo> mUserObserver           = new LiveListObserver<UserState.UserInfo>() {
        @Override
        public void onItemRemoved(int position, UserState.UserInfo item) {
            handleUserLeave(item.userId);
        }

        @Override
        public void onItemChanged(int position, UserState.UserInfo item) {
            updateFloatUserNameCard(item.userId, item.userName);
        }
    };
    private final LiveListObserver<String>             mSeatObserver           = new LiveListObserver<String>() {
        @Override
        public void onItemRemoved(int position, String item) {
            handleUserLeave(item);
        }
    };

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
    public void onEngineEvent(ConferenceEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
            case ROOM_DISMISSED:
                RoomToast.toastLongMessage(ContextProvider.getApplicationContext().getString(R.string.tuiroomkit_room_room_destroyed));
                break;
            case KICKED_OUT_OF_ROOM:
                RoomToast.toastLongMessage(ContextProvider.getApplicationContext().getString(R.string.tuiroomkit_kicked_by_master));
                break;
            case KICKED_OFF_LINE:
                RoomToast.toastLongMessage(ContextProvider.getApplicationContext().getString(R.string.tuiroomkit_kicked_off_line));
                break;
            case GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM:
                initUserInfo();
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

    private void handleEventMicStateChanged(Map<String, Object> params) {
        if (params == null || mFloatUser == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        UserEntity micUser = ConferenceController.sharedInstance().getConferenceState().allUserList.get(position);
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
        UserEntity cameraUser = ConferenceController.sharedInstance().getConferenceState().allUserList.get(position);
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
        UserEntity screenUser = ConferenceController.sharedInstance().getConferenceState().allUserList.get(position);
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
        int position = (int) params.get(ConferenceEventConstant.KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        UserEntity user = ConferenceController.sharedInstance().getConferenceState().allUserList.get(position);
        if (user.getRole() != TUIRoomDefine.Role.ROOM_OWNER) {
            return;
        }
        if (mFloatUser.isHasVideoStream() && mFloatUser.getVideoStreamType() == SCREEN_STREAM) {
            return;
        }
        if (mFloatUser.isHasVideoStream() && mFloatUser.getVideoStreamType() != SCREEN_STREAM) {
            stopVideoPlay(mFloatUser);
        }
        String userId = user.getUserId();
        mFloatUser = findUser(userId, CAMERA_STREAM);
        if (mFloatUser.isHasVideoStream()) {
            startVideoPlay(mFloatUser);
        }
        mRoomVideoFloatView.onNotifyAudioStreamStateChanged(mFloatUser.isHasAudioStream());
        mRoomVideoFloatView.onNotifyUserInfoChanged(mFloatUser);
    }

    private void handleUserLeave(String userId) {
        if (mFloatUser == null || !TextUtils.equals(userId, mFloatUser.getUserId())) {
            return;
        }
        initUserInfo();
    }

    private void updateFloatUserNameCard(String userId, String nameCard) {
        if (mFloatUser == null) {
            return;
        }
        if (TextUtils.equals(userId, mFloatUser.getUserId())) {
            mFloatUser.setUserName(nameCard);
            mRoomVideoFloatView.updateUserName(nameCard);
        }
    }

    private void handleVolumeChanged(Map<String, Integer> volumes) {
        if (mFloatUser == null) {
            return;
        }
        if (volumes == null || volumes.isEmpty()) {
            return;
        }
        updateVolumeView(volumes);
        switchVolumeUser(volumes);
    }

    private void updateVolumeView(Map<String, Integer> volumes) {
        for (Map.Entry<String, Integer> entry : volumes.entrySet()) {
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

    private void switchVolumeUser(Map<String, Integer> volumes) {
        if (isScreenSharing()) {
            return;
        }
        long curTime = SystemClock.elapsedRealtime();
        if (curTime - mLastSwitchTime < VIDEO_SWITCH_INTERVAL_MS) {
            return;
        }
        boolean isFloatUserTalking = false;
        String maxVolumeUserId = null;
        int maxVolume = 0;
        for (Map.Entry<String, Integer> entry : volumes.entrySet()) {
            int volume = entry.getValue();
            if (volume < VOLUME_CAN_HEARD_MIN_LIMIT) {
                continue;
            }
            if (TextUtils.equals(entry.getKey(), mFloatUser.getUserId())) {
                isFloatUserTalking = true;
                break;
            }
            if (volume > maxVolume) {
                maxVolume = volume;
                maxVolumeUserId = entry.getKey();
            }
        }
        if (isFloatUserTalking || TextUtils.isEmpty(maxVolumeUserId)) {
            return;
        }
        UserEntity maxVolumeUser = findUser(maxVolumeUserId, CAMERA_STREAM);
        if (maxVolumeUser == null) {
            return;
        }
        if (mFloatUser.isHasVideoStream()) {
            stopVideoPlay(mFloatUser);
        }
        mFloatUser = maxVolumeUser;
        if (mFloatUser.isHasVideoStream()) {
            startVideoPlay(mFloatUser);
        }
        mLastSwitchTime = curTime;
        mRoomVideoFloatView.onNotifyAudioStreamStateChanged(mFloatUser.isHasAudioStream());
        mRoomVideoFloatView.onNotifyUserInfoChanged(mFloatUser);
    }

    private void onPictureInPictureModeChanged(boolean isPictureInPictureMode) {
        if (ConferenceController.sharedInstance().getViewState().floatWindowType != ViewState.FloatWindowType.PICTURE_IN_PICTURE) {
            return;
        }
        if (isPictureInPictureMode) {
            if (mFloatUser.isHasVideoStream()) {
                startVideoPlay(mFloatUser);
            }
        } else {
            stopVideoPlay(mFloatUser);
        }
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
        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
        eventCenter.subscribeEngine(GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM, this);
        eventCenter.subscribeEngine(USER_ROLE_CHANGED, this);
        eventCenter.subscribeEngine(USER_CAMERA_STATE_CHANGED, this);
        eventCenter.subscribeEngine(USER_SCREEN_STATE_CHANGED, this);
        eventCenter.subscribeEngine(USER_MIC_STATE_CHANGED, this);
        eventCenter.subscribeEngine(ROOM_DISMISSED, this);
        eventCenter.subscribeEngine(KICKED_OUT_OF_ROOM, this);
        eventCenter.subscribeEngine(KICKED_OFF_LINE, this);

        ConferenceController.sharedInstance().getMediaState().volumeInfos.observe(mVolumeObserver);
        ConferenceController.sharedInstance().getUserState().allUsers.observe(mUserObserver);
        ConferenceController.sharedInstance().getSeatState().seatedUsers.observe(mSeatObserver);
        ConferenceController.sharedInstance().getViewState().isInPictureInPictureMode.observe(mIsPictureInPictureMode);
    }

    private void unRegisterNotification() {
        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
        eventCenter.unsubscribeEngine(GET_USER_LIST_COMPLETED_FOR_ENTER_ROOM, this);
        eventCenter.unsubscribeEngine(USER_ROLE_CHANGED, this);
        eventCenter.unsubscribeEngine(USER_CAMERA_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(USER_SCREEN_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(USER_MIC_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(ROOM_DISMISSED, this);
        eventCenter.unsubscribeEngine(KICKED_OUT_OF_ROOM, this);
        eventCenter.unsubscribeEngine(KICKED_OFF_LINE, this);

        ConferenceController.sharedInstance().getMediaState().volumeInfos.removeObserver(mVolumeObserver);
        ConferenceController.sharedInstance().getUserState().allUsers.removeObserver(mUserObserver);
        ConferenceController.sharedInstance().getSeatState().seatedUsers.removeObserver(mSeatObserver);
        ConferenceController.sharedInstance().getViewState().isInPictureInPictureMode.removeObserver(mIsPictureInPictureMode);
    }

    private void startVideoPlay(UserEntity userInfo) {
        if (TextUtils.equals(userInfo.getUserId(), TUILogin.getUserId())) {
            Log.d(TAG, "setLocalVideoView userId=" + userInfo.getUserId());
            ConferenceController.sharedInstance().setLocalVideoView(mVideoView);
            mRoomVideoFloatView.onNotifyVideoPlayStateChanged(true);
            return;
        }

        ConferenceController.sharedInstance()
                .setRemoteVideoView(userInfo.getUserId(), userInfo.getVideoStreamType(), mVideoView);
        Log.d(TAG, "startPlayRemoteVideo userId=" + userInfo.getUserId() + " videoStreamType="
                + userInfo.getVideoStreamType());
        ConferenceController.sharedInstance()
                .startPlayRemoteVideo(userInfo.getUserId(), userInfo.getVideoStreamType(), null);
        mRoomVideoFloatView.onNotifyVideoPlayStateChanged(true);
    }

    private void stopVideoPlay(UserEntity userInfo) {
        mRoomVideoFloatView.onNotifyVideoPlayStateChanged(false);
        if (TextUtils.equals(userInfo.getUserId(), TUILogin.getUserId())) {
            ConferenceController.sharedInstance().setLocalVideoView(null);
            return;
        }
        Log.d(TAG, "stopPlayRemoteVideo userId=" + userInfo.getUserId() + " videoStreamType="
                + userInfo.getVideoStreamType());
        ConferenceController.sharedInstance().stopPlayRemoteVideo(userInfo.getUserId(), userInfo.getVideoStreamType());
    }

    private UserEntity findUserForFloatVideo() {
        List<UserEntity> allUserList = ConferenceController.sharedInstance().getConferenceState().allUserList;
        if (allUserList.isEmpty()) {
            Log.e(TAG, "findUserForFloatVideo allUserList is empty");
            return null;
        }
        UserEntity roomOwner = null;
        UserEntity self = null;
        for (UserEntity item : allUserList) {
            if (item.isHasVideoStream() && item.getVideoStreamType() == SCREEN_STREAM && !TextUtils.equals(
                    TUILogin.getUserId(), item.getUserId())) {
                return item;
            }
            if (TextUtils.equals(item.getUserId(), ConferenceController.sharedInstance().getConferenceState().roomInfo.ownerId)
                    && item.getVideoStreamType() != SCREEN_STREAM) {
                roomOwner = item;
            }
            if (TextUtils.equals(item.getUserId(), TUILogin.getUserId())
                    && item.getVideoStreamType() != SCREEN_STREAM) {
                self = item;
            }
        }
        if (roomOwner == null) {
            return self;
        }
        return roomOwner;
    }

    public UserEntity findUser(String userId, TUIRoomDefine.VideoStreamType type) {
        List<UserEntity> allUserList = ConferenceController.sharedInstance().getConferenceState().allUserList;
        for (UserEntity item : allUserList) {
            if (TextUtils.equals(userId, item.getUserId()) && item.getVideoStreamType() == type) {
                return item;
            }
        }
        return null;
    }
}
