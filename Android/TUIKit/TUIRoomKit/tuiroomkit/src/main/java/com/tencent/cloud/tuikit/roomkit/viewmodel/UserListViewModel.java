package com.tencent.cloud.tuikit.roomkit.viewmodel;

import static com.tencent.cloud.tuikit.roomkit.model.RoomConstant.USER_NOT_FOUND;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant.KEY_USER_POSITION;

import android.content.Context;
import android.content.res.Configuration;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.component.UserListView;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class UserListViewModel
        implements RoomEventCenter.RoomEngineEventResponder, RoomEventCenter.RoomKitUIEventResponder {
    private static final String TAG             = "UserListViewModel";
    private static final int    SEAT_INDEX      = -1;
    private static final int    INVITE_TIME_OUT = 0;

    private final Context       mContext;
    private final RoomStore     mRoomStore;
    private final UserListView  mUserListView;
    private final TUIRoomEngine mRoomEngine;

    private List<UserEntity> mUserModelList;

    public UserListViewModel(Context context, UserListView userListView) {
        mContext = context;
        mUserListView = userListView;
        mRoomEngine = RoomEngineManager.sharedInstance(context).getRoomEngine();
        mRoomStore = RoomEngineManager.sharedInstance(mContext).getRoomStore();

        mUserListView.updateMuteVideoView(mRoomStore.roomInfo.isCameraDisableForAllUser);
        mUserListView.updateMuteAudioView(mRoomStore.roomInfo.isMicrophoneDisableForAllUser);
        mUserListView.updateMemberCount(mRoomStore.getTotalUserCount());
        initUserModelList();
        subscribeEvent();
    }

    private void subscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.ALL_USER_CAMERA_DISABLE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.ALL_USER_MICROPHONE_DISABLE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_CAMERA_STATE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.USER_MIC_STATE_CHANGED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_TAKE_SEAT, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_SEAT, this);
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
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_CAMERA_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.USER_MIC_STATE_CHANGED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_TAKE_SEAT, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_SEAT, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_USER_MANAGEMENT, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.INVITE_TAKE_SEAT, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    private void initUserModelList() {
        mUserListView.setOwner(isOwner());
        mUserModelList = mRoomStore.allUserList;
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

    public List<UserEntity> getUserList() {
        return mUserModelList;
    }

    public List<UserEntity> searchUserByKeyWords(String keyWords) {
        if (TextUtils.isEmpty(keyWords)) {
            return new ArrayList<>();
        }

        List<UserEntity> searchList = new ArrayList<>();
        for (UserEntity item : mRoomStore.allUserList) {
            if (item.getUserName().contains(keyWords) || item.getUserId().contains(keyWords)) {
                searchList.add(item);
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
            case USER_CAMERA_STATE_CHANGED:
                onUserCameraStateChanged(params);
                break;
            case USER_MIC_STATE_CHANGED:
                onUserMicStateChanged(params);
                break;
            case REMOTE_USER_ENTER_ROOM:
                onRemoteUserEnterRoom(params);
                mUserListView.updateMemberCount(mRoomStore.getTotalUserCount());
                break;
            case REMOTE_USER_LEAVE_ROOM:
                onRemoteUserLeaveRoom(params);
                mUserListView.updateMemberCount(mRoomStore.getTotalUserCount());
                break;
            case REMOTE_USER_TAKE_SEAT:
            case REMOTE_USER_LEAVE_SEAT:
                onRemoteUserSeatStateChanged(params);
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
    }

    private void onUserCameraStateChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        mUserListView.notifyUserStateChanged(position);
    }

    private void onUserMicStateChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        mUserListView.notifyUserStateChanged(position);
    }

    private void onRemoteUserEnterRoom(Map<String, Object> params) {
        if (params == null) {
            return;
        }

        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        mUserListView.notifyUserEnter(position);
    }

    private void onRemoteUserLeaveRoom(Map<String, Object> params) {
        if (params == null) {
            return;
        }

        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        mUserListView.notifyUserExit(position);
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        switch (key) {
            case RoomEventCenter.RoomKitUIEvent.SHOW_USER_MANAGEMENT:
                if (params == null) {
                    break;
                }
                UserEntity user = (UserEntity) params.get(RoomEventConstant.KEY_USER_MODEL);
                if (user == null) {
                    break;
                }
                mUserListView.showUserManagementView(user);
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
        UserEntity userEntity = mRoomStore.findUserWithCameraStream(mUserModelList, userId);
        if (userEntity == null) {
            return;
        }
        ToastUtil.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_toast_invite_audience_to_stage));
        mRoomEngine.takeUserOnSeatByAdmin(SEAT_INDEX, userId, INVITE_TIME_OUT, new TUIRoomDefine.RequestCallback() {
            @Override
            public void onAccepted(String requestId, String userId) {
                ToastUtil.toastShortMessageCenter(
                        mContext.getString(R.string.tuiroomkit_accept_invite, userEntity.getUserName()));
            }

            @Override
            public void onRejected(String requestId, String userId, String message) {
                ToastUtil.toastShortMessageCenter(
                        mContext.getString(R.string.tuiroomkit_reject_invite, userEntity.getUserName()));
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

    private void onRemoteUserSeatStateChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        mUserListView.notifyUserStateChanged(position);
    }
}
