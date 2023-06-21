package com.tencent.cloud.tuikit.roomkit.viewmodel;

import android.content.Context;
import android.content.res.Configuration;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;

import com.tencent.cloud.tuikit.roomkit.view.component.UserListView;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class UserListViewModel implements RoomEventCenter.RoomEngineEventResponder,
        RoomEventCenter.RoomKitUIEventResponder {
    private static final String TAG                     = "UserListViewModel";
    private static final int    SEAT_INDEX              = -1;
    private static final int    INVITE_TIME_OUT         = 0;
    private static final long   USER_LIST_NEXT_SEQUENCE = 0;

    private final Context       mContext;
    private final RoomStore     mRoomStore;
    private final UserListView  mUserListView;
    private final TUIRoomEngine mRoomEngine;

    private List<UserModel>        mUserModelList;
    private Map<String, UserModel> mUserModelMap;

    public UserListViewModel(Context context, UserListView userListView) {
        mContext = context;
        mUserListView = userListView;
        mRoomEngine = RoomEngineManager.sharedInstance(context).getRoomEngine();
        mRoomStore = RoomEngineManager.sharedInstance(mContext).getRoomStore();

        mUserModelList = new ArrayList<>();
        mUserModelMap = new HashMap<>();

        mUserListView.updateMuteVideoView(mRoomStore.roomInfo.isCameraDisableForAllUser);
        mUserListView.updateMuteAudioView(mRoomStore.roomInfo.isMicrophoneDisableForAllUser);
        initUserModelList();
        subscribeEvent();
    }

    private void subscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.ALL_USER_CAMERA_DISABLE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.ALL_USER_MICROPHONE_DISABLE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_VIDEO_STATE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_AUDIO_STATE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.SEAT_LIST_CHANGED, this);
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_USER_MANAGEMENT, this);
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.INVITE_TAKE_SEAT, this);
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public void destroy() {
        unSubscribeEvent();
    }

    private void unSubscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.ALL_USER_CAMERA_DISABLE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.ALL_USER_MICROPHONE_DISABLE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_VIDEO_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_AUDIO_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.SEAT_LIST_CHANGED, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_USER_MANAGEMENT, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.INVITE_TAKE_SEAT, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public TUIRoomDefine.SpeechMode getSpeechMode() {
        return mRoomStore.roomInfo.speechMode;
    }

    private void addMemberEntity(UserModel userModel) {
        if (userModel == null) {
            return;
        }
        if (findUserModel(userModel.userId) != null) {
            return;
        }
        mUserModelList.add(userModel);
        mUserModelMap.put(userModel.userId, userModel);
        mUserListView.addItem(userModel);
    }

    private UserModel findUserModel(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return null;
        }
        for (UserModel entity : mUserModelList) {
            if (entity == null) {
                continue;
            }
            if (userId.equals(entity.userId)) {
                return entity;
            }
        }
        return null;
    }

    private void removeMemberEntity(String userId) {
        UserModel userModel = mUserModelMap.remove(userId);
        if (userModel != null) {
            mUserModelList.remove(userModel);
        }
        mUserListView.removeItem(userModel);
    }

    private void initUserModelList() {
        mUserListView.setOwner(isOwner());
        if (isTakeSeatSpeechMode()) {
            mRoomEngine.getSeatList(new TUIRoomDefine.GetSeatListCallback() {
                @Override
                public void onSuccess(List<TUIRoomDefine.SeatInfo> list) {
                    for (TUIRoomDefine.SeatInfo seatInfo : list) {
                        UserModel userModel = new UserModel();
                        userModel.userId = seatInfo.userId;
                        userModel.isOnSeat = true;
                        addMemberEntity(userModel);
                        mRoomEngine.getUserInfo(seatInfo.userId, new TUIRoomDefine.GetUserInfoCallback() {
                            @Override
                            public void onSuccess(TUIRoomDefine.UserInfo userInfo) {
                                userModel.userName = userInfo.userName;
                                userModel.userAvatar = userInfo.avatarUrl;
                                userModel.isAudioAvailable = userInfo.hasAudioStream;
                                userModel.isVideoAvailable = userInfo.hasVideoStream;
                                userModel.role = userInfo.userRole;
                                mUserListView.updateItem(userModel);
                            }

                            @Override
                            public void onError(TUICommonDefine.Error error, String s) {

                            }
                        });
                    }
                    initListByUserList(USER_LIST_NEXT_SEQUENCE);
                }

                @Override
                public void onError(TUICommonDefine.Error error, String s) {

                }
            });
        } else {
            initListByUserList(USER_LIST_NEXT_SEQUENCE);
        }
    }

    private void initListByUserList(long sequence) {
        mRoomEngine.getUserList(sequence, new TUIRoomDefine.GetUserListCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.UserListResult userListResult) {
                for (TUIRoomDefine.UserInfo userInfo : userListResult.userInfoList) {
                    UserModel userModel = new UserModel();
                    userModel.userId = userInfo.userId;
                    userModel.userName = userInfo.userName;
                    userModel.userAvatar = userInfo.avatarUrl;
                    userModel.isAudioAvailable = userInfo.hasAudioStream;
                    userModel.isVideoAvailable = userInfo.hasVideoStream;
                    userModel.isOnSeat = false;
                    userModel.role = userInfo.userRole;
                    addMemberEntity(userModel);
                    updateRemoteUserInfo(userInfo.userId, userInfo.userName,
                            userInfo.avatarUrl);
                }
                if (userListResult.nextSequence != 0) {
                    initListByUserList(userListResult.nextSequence);
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                Log.e(TAG, "getUserList error,code:" + error + ",msg:" + s);
            }
        });
    }

    private void updateRemoteUserInfo(String userId, String userName, String userAvatar) {
        UserModel userModel = findUserModel(userId);
        if (userModel == null) {
            return;
        }
        userModel.userId = userId;
        userModel.userName = userName;
        userModel.userAvatar = userAvatar;
        mUserListView.updateItem(userModel);
    }

    private void updateUserEntityList(TUIRoomDefine.SeatInfo info) {
        String userId = info.userId;
        final UserModel userModel = new UserModel();
        userModel.userId = userId;
        userModel.isOnSeat = true;
        addMemberEntity(userModel);
        mRoomEngine.getUserInfo(userId, new TUIRoomDefine.GetUserInfoCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.UserInfo userInfo) {
                userModel.userName = userInfo.userName;
                userModel.userAvatar = userInfo.avatarUrl;
                userModel.role = userInfo.userRole;
                boolean isChangeSort = userModel.role == TUIRoomDefine.Role.ROOM_OWNER;
                if (isChangeSort) {
                    Collections.sort(mUserModelList, new Comparator<UserModel>() {
                        @Override
                        public int compare(UserModel o1, UserModel o2) {
                            if (o1.role == TUIRoomDefine.Role.ROOM_OWNER) {
                                return -1;
                            }
                            return 1;
                        }
                    });
                }
                updateRemoteUserInfo(userInfo.userId, userInfo.userName,
                        userInfo.avatarUrl);
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {

            }
        });
    }

    public String getSelfUserId() {
        return mRoomStore.userModel.userId;
    }

    public void muteAllUserAudio() {
        if (!isOwner()) {
            return;
        }
        boolean isMute = !mRoomStore.roomInfo.isMicrophoneDisableForAllUser;
        if (isMute) {
            onMuteAllUserAudio();
        } else {
            onUnMuteAllUserAudio();
        }
        mUserListView.updateMuteAudioView(isMute);
    }

    private boolean isOwner() {
        return TUIRoomDefine.Role.ROOM_OWNER.equals(mRoomStore.userModel.role);
    }

    private void onMuteAllUserAudio() {
        mRoomEngine.disableDeviceForAllUserByAdmin(TUIRoomDefine.MediaDevice.MICROPHONE, true,
                new TUIRoomDefine.ActionCallback() {
                    @Override
                    public void onSuccess() {
                        mUserListView.disableMuteAllAudio(true);
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String message) {
                        Log.e(TAG, "disableDeviceForAllUserByAdmin MICROPHONE error:" + error + ",msg:" + message);
                    }
                });
    }

    private void onUnMuteAllUserAudio() {
        mRoomEngine.disableDeviceForAllUserByAdmin(TUIRoomDefine.MediaDevice.MICROPHONE, false,
                new TUIRoomDefine.ActionCallback() {
                    @Override
                    public void onSuccess() {
                        mUserListView.disableMuteAllAudio(false);
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String message) {
                        Log.e(TAG, "enableDeviceForAllUserByAdmin MICROPHONE error:" + error + ",msg:" + message);
                    }
                });
    }

    public void muteAllUserVideo() {
        if (!isOwner()) {
            return;
        }

        boolean isMute = !mRoomStore.roomInfo.isCameraDisableForAllUser;
        if (isMute) {
            onMuteAllVideo();
        } else {
            onUnMuteAllUserVideo();
        }
        mUserListView.updateMuteVideoView(isMute);
    }

    public List<UserModel> getUserList() {
        return mUserModelList;
    }

    public List<UserModel> searchUserByKeyWords(String keyWords) {
        if (TextUtils.isEmpty(keyWords)) {
            return new ArrayList<>();
        }

        List<UserModel> searchList = new ArrayList<>();
        for (UserModel model : mUserModelList) {
            if (model == null) {
                continue;
            }
            if (model.userName.contains(keyWords) || model.userId.contains(keyWords)) {
                searchList.add(model);
            }
        }
        return searchList;
    }

    private void onMuteAllVideo() {
        mRoomEngine.disableDeviceForAllUserByAdmin(TUIRoomDefine.MediaDevice.CAMERA, true,
                new TUIRoomDefine.ActionCallback() {
                    @Override
                    public void onSuccess() {
                        mUserListView.disableMuteAllVideo(true);
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String message) {
                        Log.e(TAG, "enableDeviceForAllUserByAdmin CAMERA error:" + error + ",msg:" + message);
                    }
                });
    }

    private void onUnMuteAllUserVideo() {
        mRoomEngine.disableDeviceForAllUserByAdmin(TUIRoomDefine.MediaDevice.CAMERA, false,
                new TUIRoomDefine.ActionCallback() {
                    @Override
                    public void onSuccess() {
                        mUserListView.disableMuteAllVideo(false);
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String message) {
                        Log.e(TAG, "enableDeviceForAllUserByAdmin CAMERA error:" + error + ",msg:" + message);
                    }
                });
    }

    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
            case ALL_USER_CAMERA_DISABLE_CHANGED:
                allUserCameraDisableChanged(params);
                break;
            case ALL_USER_MICROPHONE_DISABLE_CHANGED:
                allUserMicrophoneDisableChanged(params);
                break;
            case USER_ROLE_CHANGED:
                onUserRoleChange(params);
                break;
            case USER_VIDEO_STATE_CHANGED:
                onUserVideoStateChanged(params);
                break;
            case USER_AUDIO_STATE_CHANGED:
                onUserAudioStateChanged(params);
                break;
            case REMOTE_USER_ENTER_ROOM:
                onRemoteUserEnterRoom(params);
                break;
            case REMOTE_USER_LEAVE_ROOM:
                onRemoteUserLeaveRoom(params);
                break;
            case SEAT_LIST_CHANGED:
                onSeatListChanged(params);
                break;
            default:
                break;
        }
    }

    private void allUserCameraDisableChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        if (isOwner()) {
            return;
        }
        String userId = (String) params.get(RoomEventConstant.KEY_USER_ID);
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        boolean isDisable = (Boolean) params.get(RoomEventConstant.KEY_IS_DISABLE);
        mUserListView.disableMuteAllVideo(isDisable);
    }

    private void allUserMicrophoneDisableChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        if (isOwner()) {
            return;
        }
        String userId = (String) params.get(RoomEventConstant.KEY_USER_ID);
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        boolean isDisable = (Boolean) params.get(RoomEventConstant.KEY_IS_DISABLE);
        mUserListView.disableMuteAllAudio(isDisable);
    }

    private void onUserRoleChange(Map<String, Object> params) {
        if (params == null) {
            return;
        }

        String userId = (String) params.get(RoomEventConstant.KEY_USER_ID);
        if (TextUtils.isEmpty(userId) || !mRoomStore.userModel.userId.equals(userId)) {
            return;
        }
        TUIRoomDefine.Role role = (TUIRoomDefine.Role) params.get(RoomEventConstant.KEY_ROLE);
        if (role == null) {
            return;
        }

        mUserListView.setOwner(TUIRoomDefine.Role.ROOM_OWNER.equals(role));
        mUserListView.updateMuteVideoView(mRoomStore.roomInfo.isCameraDisableForAllUser);
        mUserListView.updateMuteAudioView(mRoomStore.roomInfo.isMicrophoneDisableForAllUser);
    }

    private void onUserVideoStateChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        TUIRoomDefine.VideoStreamType streamType = (TUIRoomDefine.VideoStreamType)
                params.get(RoomEventConstant.KEY_STREAM_TYPE);
        if (TUIRoomDefine.VideoStreamType.SCREEN_STREAM.equals(streamType)) {
            return;
        }
        String userId = (String) params.get(RoomEventConstant.KEY_USER_ID);
        UserModel userModel = findUserModel(userId);
        if (userModel == null) {
            return;
        }
        userModel.isVideoAvailable = (boolean) params.get(RoomEventConstant.KEY_HAS_VIDEO);
        mUserListView.updateItem(userModel);
    }

    private void onUserAudioStateChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        String userId = (String) params.get(RoomEventConstant.KEY_USER_ID);
        UserModel userModel = findUserModel(userId);
        if (userModel == null) {
            return;
        }
        userModel.isAudioAvailable = (boolean) params.get(RoomEventConstant.KEY_HAS_AUDIO);
        mUserListView.updateItem(userModel);
    }

    private void onRemoteUserEnterRoom(Map<String, Object> params) {
        if (params == null) {
            return;
        }

        TUIRoomDefine.UserInfo userInfo = (TUIRoomDefine.UserInfo) params.get(RoomEventConstant.KEY_USER_INFO);
        if (userInfo == null) {
            return;
        }
        UserModel userModel = new UserModel();
        userModel.userId = userInfo.userId;
        userModel.userName = userInfo.userName;
        userModel.userAvatar = userInfo.avatarUrl;
        userModel.isAudioAvailable = userInfo.hasAudioStream;
        userModel.isVideoAvailable = userInfo.hasVideoStream;
        userModel.role = userInfo.userRole;
        addMemberEntity(userModel);
        updateRemoteUserInfo(userInfo.userId, userInfo.userName,
                userInfo.avatarUrl);
    }

    private void onRemoteUserLeaveRoom(Map<String, Object> params) {
        if (params == null) {
            return;
        }

        TUIRoomDefine.UserInfo userInfo = (TUIRoomDefine.UserInfo) params.get(RoomEventConstant.KEY_USER_INFO);
        if (userInfo == null) {
            return;
        }
        removeMemberEntity(userInfo.userId);
    }

    private void onSeatListChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        List<TUIRoomDefine.SeatInfo> userSeatedList = (List<TUIRoomDefine.SeatInfo>)
                params.get(RoomEventConstant.KEY_SEATED_LIST);

        if (userSeatedList != null && !userSeatedList.isEmpty()) {
            for (TUIRoomDefine.SeatInfo info :
                    userSeatedList) {
                if (isTakeSeatSpeechMode()) {
                    updateUserSeatedState(info.userId, true);
                } else {
                    updateUserEntityList(info);
                }
            }
        }

        List<TUIRoomDefine.SeatInfo> userLeftList = (List<TUIRoomDefine.SeatInfo>)
                params.get(RoomEventConstant.KEY_LEFT_LIST);
        if (userLeftList != null && !userLeftList.isEmpty()) {
            for (TUIRoomDefine.SeatInfo info :
                    userLeftList) {
                if (isTakeSeatSpeechMode()) {
                    updateUserSeatedState(info.userId, false);
                } else {
                    removeMemberEntity(info.userId);
                }
            }
        }
    }

    private boolean isTakeSeatSpeechMode() {
        return TUIRoomDefine.SpeechMode.SPEAK_AFTER_TAKING_SEAT.equals(mRoomStore.roomInfo.speechMode);
    }

    private void updateUserSeatedState(String userId, boolean isOnSeat) {
        UserModel userModel = findUserModel(userId);
        if (userModel == null) {
            return;
        }
        userModel.isOnSeat = isOnSeat;
        mUserListView.updateItem(userModel);
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        switch (key) {
            case RoomEventCenter.RoomKitUIEvent.SHOW_USER_MANAGEMENT:
                if (params == null) {
                    break;
                }
                UserModel userModel = (UserModel) params.get(RoomEventConstant.KEY_USER_MODEL);
                if (userModel == null) {
                    break;
                }
                mUserListView.showUserManagementView(userModel);
                break;
            case RoomEventCenter.RoomKitUIEvent.INVITE_TAKE_SEAT:
                if (params == null) {
                    break;
                }
                String userId = (String) params.get(RoomEventConstant.KEY_USER_ID);
                if (TextUtils.isEmpty(userId)) {
                    break;
                }
                inviteUserOnSeat(userId);
                break;
            case RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE:
                if (params == null || !mUserListView.isShowing()) {
                    break;
                }
                Configuration configuration = (Configuration) params.get(RoomEventConstant.KEY_CONFIGURATION);
                mUserListView.changeConfiguration(configuration);
                break;
            default:
                break;
        }
    }

    private void inviteUserOnSeat(final String userId) {
        final UserModel userModel = findUserModel(userId);
        if (userModel == null) {
            return;
        }
        ToastUtil.toastShortMessage(mContext.getString(R.string.tuiroomkit_toast_invite_audience_to_stage));
        mRoomEngine.takeUserOnSeatByAdmin(SEAT_INDEX, userId, INVITE_TIME_OUT, new TUIRoomDefine.RequestCallback() {
            @Override
            public void onAccepted(String requestId, String userId) {
                ToastUtil.toastShortMessage(mContext.getString(R.string.tuiroomkit_accept_invite, userModel.userName));
            }

            @Override
            public void onRejected(String requestId, String userId, String message) {
                ToastUtil.toastShortMessage(mContext.getString(R.string.tuiroomkit_reject_invite, userModel.userName));
            }

            @Override
            public void onCancelled(String requestId, String userId) {
                Log.e(TAG, "takeSeat onRejected requestId : " + requestId + ",userId:" + userId);
            }

            @Override
            public void onTimeout(String requestId, String userId) {
                Log.e(TAG, "takeSeat onTimeout userId : " + userId);
            }

            @Override
            public void onError(String requestId, String userId, TUICommonDefine.Error code, String message) {
                Log.e(TAG, "takeSeat onError userId:" + userId + ",code : " + code + ",message:" + message);
            }
        });
    }
}
