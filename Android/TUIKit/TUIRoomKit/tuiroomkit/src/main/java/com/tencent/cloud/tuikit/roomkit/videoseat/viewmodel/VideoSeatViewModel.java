package com.tencent.cloud.tuikit.roomkit.videoseat.viewmodel;

import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_ENTER_ROOM;
import static com.tencent.cloud.tuikit.roomkit.videoseat.Constants.ONE_PAGE_MEMBER_COUNT;
import static com.tencent.cloud.tuikit.roomkit.videoseat.Constants.VOLUME_CAN_HEARD_MIN_LIMIT;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomObserver;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.videoseat.ui.TUIVideoSeatView;
import com.tencent.cloud.tuikit.roomkit.videoseat.ui.view.ScaleVideoView;
import com.tencent.cloud.tuikit.roomkit.videoseat.Constants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

public class VideoSeatViewModel extends TUIRoomObserver
        implements IVideoSeatViewModel, ITUINotification, ConferenceEventCenter.RoomEngineEventResponder {
    private static final String TAG = "VideoSeatViewModel";

    private static final int SMALL_STREAM_CONDITION_USERS_NUM = 5;

    private Context          mContext;
    private TUIVideoSeatView mVideoSeatView;
    private TUIVideoView     mLocalPreview;

    private String                  mSelfUserId;
    private List<UserEntity>        mUserEntityList = new ArrayList<>();
    private Map<String, UserEntity> mUserEntityMap  = new HashMap<>();
    private UserListSorter          mUserListSorter = new UserListSorter();

    private long mNextSequence = 0;

    @Constants.SpeakerMode
    private int mLatestSpeakerMode = Constants.SPEAKER_MODE_NONE;

    private boolean mIsTwoPersonVideoMeeting = false;

    private TUIRoomEngine mRoomEngine;
    private boolean       mIsSeatEnabled;

    private TUIRoomDefine.VideoStreamType mRemoteCameraStreamType = TUIRoomDefine.VideoStreamType.CAMERA_STREAM;

    public VideoSeatViewModel(Context context, TUIVideoSeatView videoSeatView) {
        Log.d(TAG, "new : " + this);
        mContext = context;
        mVideoSeatView = videoSeatView;
        mRoomEngine = ConferenceController.sharedInstance().getRoomEngine();
        mSelfUserId = TUILogin.getUserId();

        mRoomEngine.addObserver(this);
        mVideoSeatView.setMemberEntityList(mUserEntityList);
        fetchUserList();
        TUICore.registerEvent("RoomKitEvent", "ENTER_FLOAT_WINDOW", this);
        ConferenceEventCenter.getInstance().subscribeEngine(LOCAL_USER_ENTER_ROOM, this);
    }

    @Override
    public void destroy() {
        Log.d(TAG, "destroy : " + this);
        TUICore.unRegisterEvent("RoomKitEvent", "ENTER_FLOAT_WINDOW", this);
        mRoomEngine.removeObserver(this);
        mUserEntityList.clear();
        mUserEntityMap.clear();
        ConferenceEventCenter.getInstance().unsubscribeEngine(LOCAL_USER_ENTER_ROOM, this);
    }

    @Override
    public void onEngineEvent(ConferenceEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        if (event == LOCAL_USER_ENTER_ROOM) {
            fetchUserList();
        }
    }

    @Override
    public void setLocalVideoView(UserEntity selfEntity) {
        if (selfEntity == null || selfEntity.getRoomVideoView() == mLocalPreview
                || selfEntity.isScreenShareAvailable()) {
            return;
        }
        mLocalPreview = selfEntity.getRoomVideoView();
        Log.d(TAG, "setLocalVideoView userName=" + selfEntity.getUserName() + " mLocalPreview=" + mLocalPreview);
        mRoomEngine.setLocalVideoView(mLocalPreview);
    }

    @Override
    public void startPlayVideo(String userId, TUIVideoView videoView, boolean isSharingScreen) {
        UserEntity entity = mUserEntityMap.get(userId);
        if (entity == null) {
            return;
        }
        TUIRoomDefine.VideoStreamType videoStreamType =
                entity.isScreenShareAvailable() ? TUIRoomDefine.VideoStreamType.SCREEN_STREAM : mRemoteCameraStreamType;
        entity.setVideoStreamType(videoStreamType);

        String realUserId = isSharingScreen ? userId.replace("-sub", "") : userId;
        mRoomEngine.setRemoteVideoView(realUserId, videoStreamType, videoView);
        Log.d(TAG, "startPlayRemoteVideo userId=" + userId + " videoStreamType=" + videoStreamType + " userName="
                + entity.getUserName());
        mRoomEngine.startPlayRemoteVideo(realUserId, videoStreamType, null);
        entity.setVideoPlaying(true);
        notifyUserVideoVisibilityStageChanged(userId);
    }

    @Override
    public void stopPlayVideo(String userId, boolean isSharingScreen, boolean isStreamStop) {
        UserEntity entity = mUserEntityMap.get(userId);
        if (entity == null) {
            return;
        }
        TUIRoomDefine.VideoStreamType videoStreamType = entity.getVideoStreamType();

        String realUserId = entity.isScreenShareAvailable() ? userId.replace("-sub", "") : userId;
        Log.d(TAG, "stopPlayRemoteVideo userId=" + userId + " videoStreamType=" + videoStreamType + " userName="
                + entity.getUserName());
        mRoomEngine.stopPlayRemoteVideo(realUserId, videoStreamType);
        entity.setVideoPlaying(false);
        notifyUserVideoVisibilityStageChanged(userId);
    }

    private void notifyUserVideoVisibilityStageChanged(String userId) {
        UserEntity entity = mUserEntityMap.get(userId);
        if (entity == null) {
            Log.w(TAG, "notifyUserVideoStageChanged entity is null");
            return;
        }
        mVideoSeatView.notifyItemVideoVisibilityStageChanged(mUserEntityList.indexOf(entity));
    }

    @Override
    public List<UserEntity> getData() {
        return mUserEntityList;
    }

    @Override
    public void onUserVideoStateChanged(String userId,
                                        TUIRoomDefine.VideoStreamType videoStreamType,
                                        boolean available, TUIRoomDefine.ChangeReason changeReason) {
        Log.d(TAG, "onUserVideoStateChanged userId=" + userId + " available=" + available + " videoStreamType="
                + videoStreamType + " changeReason=" + changeReason);
        UserEntity entity = mUserEntityMap.get(userId);
        if (entity == null) {
            Log.e(TAG, "onUserVideoStateChanged userId is not found");
            return;
        }

        if (TUIRoomDefine.VideoStreamType.SCREEN_STREAM.equals(videoStreamType)) {
            handleUserScreenSharingChanged(userId, available);
        } else if (TUIRoomDefine.VideoStreamType.CAMERA_STREAM.equals(videoStreamType)) {
            handleUserCameraStateChanged(userId, available);
        }

        notifyUiForUserListChanged();
    }

    private void handleUserScreenSharingChanged(String userId, boolean available) {
        UserEntity entity = mUserEntityMap.get(userId);
        if (entity == null) {
            return;
        }
        if (available) {
            if (mLatestSpeakerMode == Constants.SPEAKER_MODE_SCREEN_SHARING) {
                Log.w(TAG, "Screen sharing is started");
                return;
            }
            separateScreenShareUser(entity);
            return;
        }

        removeMemberEntity(userId + "-sub");
    }

    private void handleUserCameraStateChanged(String userId, boolean available) {
        UserEntity entity = mUserEntityMap.get(userId);
        if (entity == null) {
            return;
        }
        entity.setCameraAvailable(available);
        entity.setVideoAvailable(available);
        updateRemoteVideoStreamType();
        int position = mUserEntityList.indexOf(entity);
        mVideoSeatView.notifyItemVideoSwitchStageChanged(position);
        mUserListSorter.sortForCameraStateChangedIfNeeded(mUserEntityList, entity);
    }

    private void updateRemoteVideoStreamType() {
        int cameraStreamNum = 0;
        for (UserEntity item : mUserEntityList) {
            cameraStreamNum += item.isCameraAvailable() ? 1 : 0;
            if (cameraStreamNum > SMALL_STREAM_CONDITION_USERS_NUM) {
                break;
            }
        }
        mRemoteCameraStreamType =
                cameraStreamNum > SMALL_STREAM_CONDITION_USERS_NUM ? TUIRoomDefine.VideoStreamType.CAMERA_STREAM_LOW :
                        TUIRoomDefine.VideoStreamType.CAMERA_STREAM;
    }

    @Override
    public void onUserAudioStateChanged(String userId, boolean hasAudio, TUIRoomDefine.ChangeReason reason) {
        Log.d(TAG, "onUserAudioStateChanged userId=" + userId + " hasAudio=" + hasAudio + " reason=" + reason);
        UserEntity entity = mUserEntityMap.get(userId);
        if (entity == null) {
            return;
        }
        entity.setAudioAvailable(hasAudio);
        mVideoSeatView.notifyItemAudioStateChanged(mUserEntityList.indexOf(entity));
    }

    @Override
    public void onUserVoiceVolumeChanged(Map<String, Integer> map) {
        for (Map.Entry<String, Integer> entry : map.entrySet()) {
            if (entry.getValue() < VOLUME_CAN_HEARD_MIN_LIMIT) {
                continue;
            }
            String userId = entry.getKey();
            if (TextUtils.isEmpty(userId)) {
                continue;
            }
            UserEntity memberEntity = mUserEntityMap.get(userId);
            if (memberEntity == null || !memberEntity.isAudioAvailable()) {
                continue;
            }
            memberEntity.setAudioVolume(entry.getValue());
            memberEntity.setTalk(true);
            int position = mUserEntityList.indexOf(memberEntity);
            mVideoSeatView.notifyItemAudioStateChanged(position);
        }
    }

    @Override
    public void onSeatListChanged(List<TUIRoomDefine.SeatInfo> seatList,
                                  List<TUIRoomDefine.SeatInfo> userSeatedList,
                                  List<TUIRoomDefine.SeatInfo> userLeftList) {
        Log.d(TAG, "onSeatListChanged");
        removeLeftUsers(userLeftList);
        addNewUsers(userSeatedList, false);
    }

    @Override
    public void onRemoteUserEnterRoom(String roomId, TUIRoomDefine.UserInfo userInfo) {
        if (isSeatEnable()) {
            return;
        }
        Log.d(TAG, "onRemoteUserEnterRoom userId=" + userInfo.userId + " userName=" + userInfo.userName + " videoOn="
                + userInfo.hasVideoStream);
        UserEntity userEntity = getNewFreeUser(userInfo);
        addMemberEntity(userEntity);
        notifyUiForUserListChanged();
    }

    @Override
    public void onRemoteUserLeaveRoom(String roomId, TUIRoomDefine.UserInfo userInfo) {
        if (isSeatEnable()) {
            return;
        }
        Log.d(TAG, "onRemoteUserLeaveRoom userId=" + userInfo.userId + " userName=" + userInfo.userName + " videoOn="
                + userInfo.hasVideoStream);
        removeMemberEntity(userInfo.userId + "-sub");
        removeMemberEntity(userInfo.userId);
        notifyUiForUserListChanged();
    }

    @Override
    public void onUserRoleChanged(String userId, TUIRoomDefine.Role userRole) {
        Log.d(TAG, "onUserRoleChanged userId=" + userId + " userRole=" + userRole);
        UserEntity userEntity = mUserEntityMap.get(userId);
        if (userEntity == null) {
            Log.w(TAG, "onUserRoleChanged userId is not record.");
            return;
        }
        userEntity.setRole(userRole);
        notifyUiForUserListChanged();
        mVideoSeatView.notifyDataSetChanged();
    }

    private void fetchUserList() {
        if (TextUtils.isEmpty(ConferenceController.sharedInstance().getConferenceState().roomInfo.roomId)) {
            return;
        }
        Log.d(TAG, "fetchRoomInfo");
        mRoomEngine.fetchRoomInfo(new TUIRoomDefine.GetRoomInfoCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.RoomInfo roomInfo) {
                if (roomInfo == null) {
                    Log.e(TAG, "fetchRoomInfo onSuccess roomInfo is null");
                    return;
                }
                mIsSeatEnabled = roomInfo.isSeatEnabled;
                Log.d(TAG, "fetchRoomInfo onSuccess isSeatEnabled=" + roomInfo.isSeatEnabled);
                if (isSeatEnable()) {
                    getSeatList();
                } else {
                    getUserList();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                Log.e(TAG, "fetchRoomInfo error=" + error + "  s=" + s);
            }
        });
    }

    private boolean isSeatEnable() {
        return mIsSeatEnabled;
    }

    private void getSeatList() {
        Log.d(TAG, "getSeatList");
        mRoomEngine.getSeatList(new TUIRoomDefine.GetSeatListCallback() {
            @Override
            public void onSuccess(List<TUIRoomDefine.SeatInfo> list) {
                Log.d(TAG, "getSeatList onSuccess size=" + list.size());
                addNewUsers(list, true);
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                Log.e(TAG, "getSeatList error=" + error + "  s=" + s);
            }
        });
    }

    private void getUserList() {
        Log.d(TAG, "getUserList");
        mRoomEngine.getUserList(mNextSequence, new TUIRoomDefine.GetUserListCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.UserListResult userListResult) {
                Log.d(TAG, "getUserList onSuccess nextSequence=" + userListResult.nextSequence);
                mNextSequence = userListResult.nextSequence;
                addNewFreeUsers(userListResult.userInfoList);
                if (mNextSequence != 0) {
                    getUserList();
                } else {
                    startPlayVideoAfterEnterRoomCompleted();
                    notifyUiForUserListChanged();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                Log.d(TAG, "getUserList onError error=" + error + "  s=" + s);
            }
        });
    }

    private void separateScreenShareUser(UserEntity entity) {
        entity.setScreenShareAvailable(false);
        entity.setVideoAvailable(entity.isCameraAvailable());
        UserEntity shareUserEntity = entity.copy();
        final ScaleVideoView roomVideoView = new ScaleVideoView(mContext);
        roomVideoView.enableScale(true);
        shareUserEntity.setRoomVideoView(roomVideoView);
        shareUserEntity.setCameraAvailable(false);
        shareUserEntity.setScreenShareAvailable(true);
        shareUserEntity.setVideoAvailable(true);
        shareUserEntity.setUserId(entity.getUserId() + "-sub");
        addMemberEntity(shareUserEntity);
    }

    private void addNewFreeUsers(List<TUIRoomDefine.UserInfo> addList) {
        for (TUIRoomDefine.UserInfo item : addList) {
            UserEntity userEntity = getNewFreeUser(item);
            if (userEntity.isScreenShareAvailable()) {
                separateScreenShareUser(userEntity);
            }
            addMemberEntity(userEntity);
        }
    }

    private UserEntity getNewFreeUser(TUIRoomDefine.UserInfo userInfo) {
        UserEntity entity = new UserEntity();
        entity.setUserId(userInfo.userId);
        final TUIVideoView roomVideoView = new TUIVideoView(mContext);
        roomVideoView.setUserId(userInfo.userId);
        entity.setRoomVideoView(roomVideoView);
        if (userInfo.userId.equals(mSelfUserId)) {
            entity.setSelf(true);
            // When you first enter the room, the SDK may not call back the information that your video has been opened.
            setLocalVideoView(entity);
        }
        entity.setUserName(userInfo.userName);
        entity.setUserAvatar(userInfo.avatarUrl);
        entity.setRole(userInfo.userRole);
        entity.setAudioAvailable(userInfo.hasAudioStream);
        entity.setScreenShareAvailable(userInfo.hasScreenStream);
        entity.setCameraAvailable(userInfo.hasVideoStream);
        entity.setVideoAvailable(entity.isScreenShareAvailable() || entity.isCameraAvailable());
        return entity;
    }

    private void removeLeftUsers(List<TUIRoomDefine.SeatInfo> leftList) {
        for (TUIRoomDefine.SeatInfo info : leftList) {
            Log.d(TAG, "removeLeftUsers info.userId=" + info.userId);
            removeMemberEntity(info.userId + "-sub");
            removeMemberEntity(info.userId);
        }
        if (!leftList.isEmpty()) {
            notifyUiForUserListChanged();
        }
    }

    private void addNewUsers(List<TUIRoomDefine.SeatInfo> addList, boolean needStartPlayVideo) {
        if (addList.isEmpty()) {
            return;
        }
        final int totalCount = addList.size();
        final AtomicInteger resultCount = new AtomicInteger(0);
        for (TUIRoomDefine.SeatInfo info : addList) {
            final UserEntity entity = createUserEntity(info);
            Log.d(TAG, "addNewUsers getUserInfo info.userId=" + info.userId);
            if (TextUtils.isEmpty(info.userId)) {
                notifyUiUpdateIfCompleteUserInfoFetch(resultCount, totalCount, needStartPlayVideo);
                continue;
            }
            mRoomEngine.getUserInfo(info.userId, new TUIRoomDefine.GetUserInfoCallback() {
                @Override
                public void onSuccess(TUIRoomDefine.UserInfo userInfo) {
                    updateUserEntity(entity, userInfo);
                    Log.d(TAG, "addNewUsers onSuccess info.userId=" + info.userId + " entity.userName="
                            + entity.getUserName() + " videoOn=" + entity.isVideoAvailable());
                    if (entity.isScreenShareAvailable()) {
                        separateScreenShareUser(entity);
                    }
                    addMemberEntity(entity);
                    notifyUiUpdateIfCompleteUserInfoFetch(resultCount, totalCount, needStartPlayVideo);
                }

                @Override
                public void onError(TUICommonDefine.Error error, String s) {
                    Log.e(TAG, "addNewUsers onError info.userId=" + info.userId + " error=" + error + " s=" + s);
                    notifyUiUpdateIfCompleteUserInfoFetch(resultCount, totalCount, needStartPlayVideo);
                }
            });
        }
    }

    private UserEntity createUserEntity(TUIRoomDefine.SeatInfo info) {
        UserEntity entity = new UserEntity();
        entity.setUserId(info.userId);
        final TUIVideoView roomVideoView = new TUIVideoView(mContext);
        roomVideoView.setUserId(info.userId);
        entity.setRoomVideoView(roomVideoView);
        if (info.userId.equals(mSelfUserId)) {
            entity.setSelf(true);
        }
        return entity;
    }

    private void updateUserEntity(UserEntity entity, TUIRoomDefine.UserInfo userInfo) {
        entity.setUserName(userInfo.userName);
        entity.setUserAvatar(userInfo.avatarUrl);
        entity.setRole(userInfo.userRole);
        entity.setAudioAvailable(userInfo.hasAudioStream);
        entity.setScreenShareAvailable(userInfo.hasScreenStream);
        entity.setCameraAvailable(userInfo.hasVideoStream);
        entity.setVideoAvailable(entity.isScreenShareAvailable() || entity.isCameraAvailable());
    }

    private void notifyUiUpdateIfCompleteUserInfoFetch(AtomicInteger resultCount, int totalCount,
                                                       boolean needStartPlayVideo) {
        resultCount.addAndGet(1);
        if (resultCount.get() < totalCount) {
            return;
        }
        notifyUiForUserListChanged();
        if (needStartPlayVideo) {
            startPlayVideoAfterEnterRoomCompleted();
        }
    }

    private void startPlayVideoAfterEnterRoomCompleted() {
        if (mUserEntityList.isEmpty()) {
            return;
        }
        int minVisibleUserIndex = 0;
        int maxVisibleUserIndex = Math.min(mUserEntityList.size(), ONE_PAGE_MEMBER_COUNT);
        maxVisibleUserIndex = mLatestSpeakerMode == Constants.SPEAKER_MODE_NONE ? maxVisibleUserIndex : 0;
        for (int i = minVisibleUserIndex; i < maxVisibleUserIndex; i++) {
            UserEntity userEntity = mUserEntityList.get(i);
            if (userEntity == null || !userEntity.isVideoAvailable()) {
                continue;
            }
            if (userEntity.isSelf()) {
                setLocalVideoView(userEntity);
            } else {
                startPlayVideo(userEntity.getUserId(), userEntity.getRoomVideoView(),
                        userEntity.isScreenShareAvailable());
            }
        }
    }

    private void notifyUiForUserListChanged() {
        mUserListSorter.sortList(mUserEntityList);
        notifySpeakerModeChangedIfNeeded();
        notifyTwoPersonVideoMeetingChangedIfNeeded();
    }

    private void addMemberEntity(UserEntity entity) {
        if (mUserEntityMap.containsKey(entity.getUserId())) {
            Log.w(TAG, "addMemberEntity userId is existed : " + entity.getUserId());
            return;
        }
        int position = mUserListSorter.insertUser(mUserEntityList, entity);
        mVideoSeatView.notifyItemInserted(position);
        mUserEntityMap.put(entity.getUserId(), entity);
        if (entity.isSelf()) {
            // When you first enter the room, the SDK may not call back the information that your video has been opened.
            setLocalVideoView(entity);
        }
    }

    private void removeMemberEntity(String userId) {
        if (!mUserEntityMap.containsKey(userId)) {
            return;
        }
        UserEntity entity = mUserEntityMap.get(userId);
        int position = mUserListSorter.removeUser(mUserEntityList, entity);
        mVideoSeatView.notifyItemRemoved(position);
        mUserEntityMap.remove(userId);
    }

    /**
     * newSpeakerMode and oldSpeakerMode have three types: SPEAKER_MODE_NONE, SPEAKER_MODE_NONE and SPEAKER_MODE_PERSONAL_SPEECH, with values 0, 1 and 2 respectively.
     * New and old can be combined into 9 combinations, many-to-one mapping to the three operations of speaker mode: keep, close, and open;
     * When switching from screen sharing to personal speech, the speaker mode also needs to be re-opened in order to refresh the screen and read new data from the Adapter.
     *
     * o\n  0     1     2
     * 0    keep  on    on
     * 1    off   keep  on
     * 2    off   on    keep
     */
    private void notifySpeakerModeChangedIfNeeded() {
        @Constants.SpeakerMode int newSpeakerMode = getSpeakerModeFromData();
        if (mLatestSpeakerMode == newSpeakerMode) {
            return;
        }
        mVideoSeatView.enableSpeakerMode(newSpeakerMode != Constants.SPEAKER_MODE_NONE);
        mLatestSpeakerMode = newSpeakerMode;
    }

    private @Constants.SpeakerMode int getSpeakerModeFromData() {
        if (mUserListSorter.isSpeakerOfScreenSharing(mUserEntityList)) {
            return Constants.SPEAKER_MODE_SCREEN_SHARING;
        }
        if (mUserEntityList.size() < Constants.SPEAKER_MODE_MEMBER_MIN_LIMIT) {
            return Constants.SPEAKER_MODE_NONE;
        }
        if (mUserListSorter.isSpeakerOfPersonalVideoShow(mUserEntityList)) {
            return Constants.SPEAKER_MODE_PERSONAL_VIDEO_SHOW;
        }
        return Constants.SPEAKER_MODE_NONE;
    }

    /** o\n  0     1
     * 0    keep  on
     * 1    off   keep
     */
    private void notifyTwoPersonVideoMeetingChangedIfNeeded() {
        boolean isTwoPersonVideoMeeting = isTwoPersonVideoMeetingFromData();
        if (isTwoPersonVideoMeeting != mIsTwoPersonVideoMeeting) {
            mVideoSeatView.enableTwoPersonVideoMeeting(isTwoPersonVideoMeeting);
            mIsTwoPersonVideoMeeting = isTwoPersonVideoMeeting;
            return;
        }
        if (isTwoPersonVideoMeeting) {
            mVideoSeatView.notifyTalkingViewDataChanged();
        }
    }

    private boolean isTwoPersonVideoMeetingFromData() {
        if (mUserEntityList.size() != Constants.TWO_PERSON_VIDEO_CONFERENCE_MEMBER_COUNT) {
            return false;
        }
        if (!mUserEntityList.get(0).isVideoAvailable() && !mUserEntityList.get(1).isVideoAvailable()) {
            return false;
        }
        if (mUserEntityList.get(0).isScreenShareAvailable() || mUserEntityList.get(1).isScreenShareAvailable()) {
            return false;
        }
        return true;
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        Log.d(TAG, "onNotifyEvent key=" + key + " subKey=" + subKey);
        if (TextUtils.equals("RoomKitEvent", key) && TextUtils.equals("ENTER_FLOAT_WINDOW", subKey)) {
            stopAllRemoteVideo();
            return;
        }
    }

    private void stopAllRemoteVideo() {
        for (UserEntity item : mUserEntityList) {
            if (item.isVideoPlaying() && !item.isSelf()) {
                stopPlayVideo(item.getUserId(), false, false);
            }
        }
    }
}