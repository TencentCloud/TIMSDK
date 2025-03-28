package com.tencent.cloud.tuikit.roomkit.state;

import android.text.TextUtils;

import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.qcloud.tuicore.TUILogin;
import com.trtc.tuikit.common.livedata.LiveData;
import com.trtc.tuikit.common.livedata.LiveListData;

public class UserState {
    public LiveData<UserInfo> selfInfo = new LiveData<>(new UserInfo(TUILogin.getUserId()));

    public LiveListData<UserInfo> allUsers = new LiveListData<>();

    public LiveListData<String> hasAudioStreamUsers      = new LiveListData<>();
    public LiveListData<String> hasCameraStreamUsers     = new LiveListData<>();
    public LiveListData<String> playBigCameraStreamUsers = new LiveListData<>();
    public LiveListData<String> disableMessageUsers      = new LiveListData<>();

    public LiveData<String>         screenStreamUser = new LiveData<>("");
    public LiveData<UserVolumeInfo> userVolumeInfo   = new LiveData<>(new UserVolumeInfo("", 0));

    public void remoteUserEnterRoom(TUIRoomDefine.UserInfo userInfo) {
        UserInfo user = new UserInfo(userInfo);
        if (allUsers.contains(user)) {
            return;
        }
        UserInfo self = selfInfo.get();
        if (TextUtils.equals(userInfo.userId, self.userId)) {
            self.updateUserInfo(userInfo);
            selfInfo.set(self);
        }
        allUsers.add(user);
        if (userInfo.isMessageDisabled) {
            disableMessageUsers.add(userInfo.userId);
        }
    }

    public void remoteUserLeaveRoom(TUIRoomDefine.UserInfo userInfo) {
        UserInfo user = new UserInfo(userInfo);
        allUsers.remove(user);
        disableMessageUsers.remove(userInfo.userId);
    }

    public void userNameCardChanged(TUIRoomDefine.UserInfo userInfo) {
        UserInfo user = new UserInfo(userInfo);
        allUsers.change(user);
    }

    public void handleUserRoleChanged(TUIRoomDefine.UserInfo userInfo) {
        UserInfo self = selfInfo.get();
        if (TextUtils.equals(userInfo.userId, self.userId)) {
            self.updateUserInfo(userInfo);
            selfInfo.set(self);
        }
        UserInfo user = new UserInfo(userInfo);
        allUsers.change(user);
    }

    public void updateUserAudioState(String userId, boolean hasAudioStream) {
        if (hasAudioStream) {
            hasAudioStreamUsers.add(userId);
        } else {
            hasAudioStreamUsers.remove(userId);
        }
    }

    public void updateUserCameraState(String userId, boolean hasCameraStream,
                                      TUIRoomDefine.VideoStreamType streamType) {
        if (hasCameraStream) {
            hasCameraStreamUsers.add(userId);
            if (streamType == TUIRoomDefine.VideoStreamType.CAMERA_STREAM) {
                playBigCameraStreamUsers.add(userId);
            }
        } else {
            hasCameraStreamUsers.remove(userId);
            if (streamType == TUIRoomDefine.VideoStreamType.CAMERA_STREAM) {
                playBigCameraStreamUsers.remove(userId);
            }
        }
    }

    public void updateUserScreenState(String userId, boolean hasScreenStream) {
        String sharingUserId = screenStreamUser.get();
        if (hasScreenStream && TextUtils.isEmpty(sharingUserId)) {
            screenStreamUser.set(userId);
            return;
        }
        if (!hasScreenStream && TextUtils.equals(userId, sharingUserId)) {
            screenStreamUser.set("");
        }
    }

    public void updateUserMessageState(String userId, boolean isDisable) {
        if (isDisable) {
            disableMessageUsers.add(userId);
        } else {
            disableMessageUsers.remove(userId);
        }
    }

    public static class UserInfo {
        public String                       userId    = "";
        public String                       userName  = "";
        public String                       avatarUrl = "";
        public LiveData<TUIRoomDefine.Role> role      = new LiveData<>(TUIRoomDefine.Role.GENERAL_USER);

        public UserInfo(String userId) {
            this.userId = userId;
        }

        public UserInfo(TUIRoomDefine.UserInfo userInfo) {
            updateUserInfo(userInfo);
        }

        public void updateUserInfo(TUIRoomDefine.UserInfo userInfo) {
            this.userId = userInfo.userId;
            this.userName = TextUtils.isEmpty(userInfo.nameCard) ? userInfo.userName : userInfo.nameCard;
            this.avatarUrl = userInfo.avatarUrl;
            this.role.set(userInfo.userRole);
        }

        @Override
        public boolean equals(@Nullable Object obj) {
            if (obj instanceof UserInfo) {
                return TextUtils.equals(this.userId, ((UserInfo) obj).userId);
            }
            return false;
        }
    }

    public static class UserVolumeInfo {
        public String userId;
        public int    volume;

        public UserVolumeInfo(String userId, int volume) {
            this.userId = userId;
            this.volume = volume;
        }

        public void update(String userId, int volume) {
            this.userId = userId;
            this.volume = volume;
        }
    }
}

