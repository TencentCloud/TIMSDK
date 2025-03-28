package com.tencent.cloud.tuikit.roomkit.view.main.videoseat.viewmodel;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_ENTER_ROOM;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomObserver;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.main.videoseat.constant.Constants;
import com.tencent.cloud.tuikit.roomkit.view.main.videoseat.ui.view.ConferenceVideoView;
import com.tencent.cloud.tuikit.roomkit.view.main.videoseat.TUIVideoSeatView;
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
    private static final String TAG            = "VideoSeatViewModel";
    private static final String ROOM_KIT_EVENT = "ROOM_KIT_EVENT";

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
    private boolean       mIsSeatEnabled = true;

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
        TUICore.registerEvent(ROOM_KIT_EVENT, "ENTER_FLOAT_WINDOW", this);
        ConferenceEventCenter.getInstance().subscribeEngine(LOCAL_USER_ENTER_ROOM, this);
    }

    @Override
    public void destroy() {
        Log.d(TAG, "destroy : " + this);
        TUICore.unRegisterEvent(ROOM_KIT_EVENT, "ENTER_FLOAT_WINDOW", this);
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
        if (selfEntity == null) {
            return;
        }
        Log.d(TAG, "setLocalVideoView userId=" + selfEntity.getUserId() + " isCameraAvailable=" + selfEntity.isCameraAvailable());
        mRoomEngine.setLocalVideoView(selfEntity.isCameraAvailable() ? selfEntity.getRoomVideoView() : null);
        notifyUserVideoVisibilityStageChanged(selfEntity.getUserId());
    }

    @Override
    public void toggleScreenSizeOnDoubleClick(int position) {
        Log.d(TAG, "toggleScreenSizeOnDoubleClick position=" + position);
        UserEntity firstUser = mUserEntityList.get(0);
        if (position == 0) {
            if (firstUser.isSelected()) {
                handleUserSelectStateChanged(firstUser);
            } else {
                firstUser.setSelected(true);
            }
            notifyUiForUserListChanged();
            return;
        }

        UserEntity curUser = mUserEntityList.get(position);
        if (firstUser.isSelected()) {
            handleUserSelectStateChanged(firstUser);
        }
        handleUserSelectStateChanged(curUser);
        notifyUiForUserListChanged();
        mVideoSeatView.enableSpeakerMode(true);
    }

    private void handleUserSelectStateChanged(UserEntity user) {
        user.setSelected(!user.isSelected());
        int fromIndex = mUserListSorter.removeUser(mUserEntityList, user);
        int toIndex = mUserListSorter.insertUser(mUserEntityList, user);
        mVideoSeatView.notifyItemMoved(fromIndex, toIndex);
    }

    @Override
    public void startPlayVideo(String userId, TUIVideoView videoView, boolean isSharingScreen) {
        UserEntity entity = mUserEntityMap.get(userId);
        if (entity == null || entity.isVideoPlaying()) {
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
        if (entity == null || !entity.isVideoPlaying()) {
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
        mVideoSeatView.notifyItemVideoVisibilityStageChanged(entity);
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

    @Override
    public void onUserInfoChanged(TUIRoomDefine.UserInfo userInfo, List<TUIRoomDefine.UserInfoModifyFlag> modifyFlag) {
        Log.d(TAG, "onUserInfoChanged userId=" + userInfo.userId);
        UserEntity userEntity = mUserEntityMap.get(userInfo.userId);
        if (userEntity == null) {
            Log.w(TAG, "onUserInfoChanged userId is not record.");
            return;
        }
        if (modifyFlag.contains(TUIRoomDefine.UserInfoModifyFlag.NAME_CARD)) {
            userEntity.setUserName(userInfo.nameCard);
            mVideoSeatView.notifyDataSetChanged();
        }
        if (modifyFlag.contains(TUIRoomDefine.UserInfoModifyFlag.USER_ROLE)) {
            userEntity.setRole(userInfo.userRole);
            notifyUiForUserListChanged();
            mVideoSeatView.notifyDataSetChanged();
        }
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
            UserEntity shareUser = separateScreenShareUser(entity);
            startPlayVideo(shareUser.getUserId(), shareUser.getRoomVideoView(), true);
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
        int fromPosition = mUserEntityList.indexOf(entity);
        mVideoSeatView.notifyItemVideoSwitchStageChanged(fromPosition);
        mUserListSorter.sortList(mUserEntityList);
        int toPosition = mUserEntityList.indexOf(entity);
        if (fromPosition != toPosition) {
            mVideoSeatView.notifySortMove(fromPosition, toPosition);
        }
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
        int fromPosition = mUserEntityList.indexOf(entity);
        mVideoSeatView.notifyItemAudioStateChanged(fromPosition);
        mUserListSorter.sortList(mUserEntityList);
        int toPosition = mUserEntityList.indexOf(entity);
        if (fromPosition != toPosition) {
            mVideoSeatView.notifySortMove(fromPosition, toPosition);
        }
    }

    @Override
    public void onUserVoiceVolumeChanged(Map<String, Integer> map) {
        for (Map.Entry<String, Integer> entry : map.entrySet()) {
            if (entry.getValue() < Constants.VOLUME_CAN_HEARD_MIN_LIMIT) {
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
                    notifyUiForUserListChanged();
                    startPlayVideoAfterEnterRoomCompleted();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                Log.d(TAG, "getUserList onError error=" + error + "  s=" + s);
            }
        });
    }

    private UserEntity separateScreenShareUser(UserEntity entity) {
        entity.setScreenShareAvailable(false);
        entity.setVideoAvailable(entity.isCameraAvailable());
        UserEntity shareUserEntity = entity.copy();
        final ConferenceVideoView roomVideoView = new ConferenceVideoView(mContext);
        shareUserEntity.setRoomVideoView(roomVideoView);
        shareUserEntity.setCameraAvailable(false);
        shareUserEntity.setScreenShareAvailable(true);
        shareUserEntity.setVideoAvailable(true);
        shareUserEntity.setUserId(entity.getUserId() + "-sub");
        addMemberEntity(shareUserEntity);
        return shareUserEntity;
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
        final ConferenceVideoView roomVideoView = new ConferenceVideoView(mContext);
        roomVideoView.setUserId(userInfo.userId);
        entity.setRoomVideoView(roomVideoView);
        if (userInfo.userId.equals(mSelfUserId)) {
            entity.setSelf(true);
        }
        entity.setUserName(TextUtils.isEmpty(userInfo.nameCard) ? userInfo.userName : userInfo.nameCard);
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
        final ConferenceVideoView roomVideoView = new ConferenceVideoView(mContext);
        roomVideoView.setUserId(info.userId);
        entity.setRoomVideoView(roomVideoView);
        if (info.userId.equals(mSelfUserId)) {
            entity.setSelf(true);
        }
        return entity;
    }

    private void updateUserEntity(UserEntity entity, TUIRoomDefine.UserInfo userInfo) {
        entity.setUserName(TextUtils.isEmpty(userInfo.nameCard) ? userInfo.userName : userInfo.nameCard);
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
        updateRemoteVideoStreamType();
        int minVisibleUserIndex = 0;
        int maxVisibleUserIndex = Math.min(mUserEntityList.size() - 1, Constants.ONE_PAGE_MEMBER_COUNT - 1);
        maxVisibleUserIndex = mLatestSpeakerMode == Constants.SPEAKER_MODE_NONE ? maxVisibleUserIndex : 0;
        mVideoSeatView.processVideoPlay(minVisibleUserIndex, maxVisibleUserIndex);
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
     * <p>
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
        if (mUserEntityList.size() < Constants.SPEAKER_MODE_MEMBER_MIN_LIMIT) {
            return Constants.SPEAKER_MODE_NONE;
        }
        if (mUserListSorter.isSpeakerOfSelected(mUserEntityList)) {
            return Constants.SPEAKER_MODE_SELECTED;
        }
        if (mUserListSorter.isSpeakerOfScreenSharing(mUserEntityList)) {
            return Constants.SPEAKER_MODE_SCREEN_SHARING;
        }
        if (mUserListSorter.isSpeakerOfPersonalVideoShow(mUserEntityList)) {
            return Constants.SPEAKER_MODE_PERSONAL_VIDEO_SHOW;
        }
        return Constants.SPEAKER_MODE_NONE;
    }

    /**
     * o\n  0     1
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
        return true;
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        Log.d(TAG, "onNotifyEvent key=" + key + " subKey=" + subKey);
        if (TextUtils.equals(ROOM_KIT_EVENT, key) && TextUtils.equals("ENTER_FLOAT_WINDOW", subKey)) {
            ConferenceController.sharedInstance().setLocalVideoView(null);
            stopAllRemoteVideo();
            return;
        }
    }

    private void stopAllRemoteVideo() {
        for (UserEntity item : mUserEntityList) {
            if (item.isVideoPlaying() && !item.isSelf()) {
                ConferenceController.sharedInstance().setRemoteVideoView(item.getUserId(), item.getVideoStreamType(), null);
                stopPlayVideo(item.getUserId(), false, false);
            }
        }
    }
}