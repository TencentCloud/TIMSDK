package com.tencent.cloud.tuikit.roomkit.model.data;

import android.text.TextUtils;

import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.common.livedata.LiveListData;
import com.tencent.qcloud.tuicore.TUILogin;
import com.trtc.tuikit.common.livedata.LiveData;

import java.util.LinkedHashSet;

public class UserState {
    public LiveData<UserInfo> selfInfo = new LiveData<>(new UserInfo(TUILogin.getUserId()));

    public LiveListData<UserInfo> allUsers = new LiveListData<>();

    public LiveData<LinkedHashSet<String>> hasAudioStreamUsers  = new LiveData<>(new LinkedHashSet<>());
    public LiveData<LinkedHashSet<String>> hasCameraStreamUsers = new LiveData<>(new LinkedHashSet<>());
    //   public LiveData<LinkedHashSet<String>> playBigCameraStreamUsers = new LiveData<>(new LinkedHashSet<>());
    public LiveData<LinkedHashSet<String>> disableMessageUsers  = new LiveData<>(new LinkedHashSet<>());
    public LiveData<String>                hasScreenStreamUser  = new LiveData<>("");

    //   public LiveData<UserVolumeInfo> userVolumeInfo = new LiveData<>(new UserVolumeInfo());

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

    public void updateUserCameraState(String userId, boolean hasCameraStream) {
        if (hasCameraStream) {
            hasCameraStreamUsers.add(userId);
        } else {
            hasCameraStreamUsers.remove(userId);
        }
    }

    public void updateUserScreenState(String userId, boolean hasScreenStream) {
        String sharingUserId = hasScreenStreamUser.get();
        if (hasScreenStream && TextUtils.isEmpty(sharingUserId)) {
            hasScreenStreamUser.set(userId);
            return;
        }
        if (!hasScreenStream && TextUtils.equals(userId, sharingUserId)) {
            hasScreenStreamUser.set(null);
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
        public String             userId    = "";
        public String             userName  = "";
        public String             avatarUrl = "";
        public TUIRoomDefine.Role role      = TUIRoomDefine.Role.GENERAL_USER;

        public UserInfo(String userId) {
            this.userId = userId;
        }

        public UserInfo(TUIRoomDefine.UserInfo userInfo) {
            updateUserInfo(userInfo);
        }

        public void updateUserInfo(TUIRoomDefine.UserInfo userInfo) {
            this.userId = userInfo.userId;
            this.userName = userInfo.userName;
            this.avatarUrl = userInfo.avatarUrl;
            this.role = userInfo.userRole;
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
        public String userId = "";
        public int    volume = 0;
    }
}

