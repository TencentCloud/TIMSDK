package com.tencent.cloud.tuikit.roomkit;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;

import java.io.Serializable;
import java.util.Objects;

public class ConferenceDefine {
    public static final String KEY_START_CONFERENCE_PARAMS = "KEY_START_CONFERENCE_PARAMS";
    public static final String KEY_JOIN_CONFERENCE_PARAMS  = "KEY_JOIN_CONFERENCE_PARAMS";

    public static class StartConferenceParams implements Serializable {
        public final String roomId;

        public boolean isOpenMicrophone = true;
        public boolean isOpenCamera     = false;
        public boolean isOpenSpeaker    = true;

        public boolean isMicrophoneDisableForAllUser = false;
        public boolean isCameraDisableForAllUser     = false;

        public boolean isSeatEnabled = false;
        public String  password      = "";
        public String  name          = "";

        public StartConferenceParams(String roomId) {
            this.roomId = roomId;
        }

        @NonNull
        @Override
        public String toString() {
            StringBuilder builder = new StringBuilder();
            builder.append("roomId=").append(roomId);
            builder.append("; isOpenMicrophone=").append(isOpenMicrophone);
            builder.append("; isOpenCamera=").append(isOpenCamera);
            builder.append("; isOpenSpeaker=").append(isOpenSpeaker);
            builder.append("; isMicrophoneDisableForAllUser=").append(isMicrophoneDisableForAllUser);
            builder.append("; isCameraDisableForAllUser=").append(isCameraDisableForAllUser);
            builder.append("; isSeatEnabled=").append(isSeatEnabled);
            builder.append("; password=").append(password);
            builder.append("; name=").append(name);
            return builder.toString();
        }
    }

    public static class JoinConferenceParams implements Serializable {
        public final String roomId;

        public boolean isOpenMicrophone = true;
        public boolean isOpenCamera     = false;
        public boolean isOpenSpeaker    = true;

        public JoinConferenceParams(String roomId) {
            this.roomId = roomId;
        }

        @NonNull
        @Override
        public String toString() {
            StringBuilder builder = new StringBuilder();
            builder.append("roomId=").append(roomId);
            builder.append("; isOpenMicrophone=").append(isOpenMicrophone);
            builder.append("; isOpenCamera=").append(isOpenCamera);
            builder.append("; isOpenSpeaker=").append(isOpenSpeaker);
            return builder.toString();
        }
    }

    public static abstract class ConferenceObserver {
        public void onConferenceStarted(TUIRoomDefine.RoomInfo roomInfo, TUICommonDefine.Error error, String message) {}

        public void onConferenceJoined(TUIRoomDefine.RoomInfo roomInfo, TUICommonDefine.Error error, String message) {}

        public void onConferenceExited(TUIRoomDefine.RoomInfo roomInfo, ConferenceExitedReason reason) {}

        public void onConferenceFinished(TUIRoomDefine.RoomInfo roomInfo, ConferenceFinishedReason reason) {}
    }

    public enum ConferenceFinishedReason {
        FINISHED_BY_OWNER,
        FINISHED_BY_SERVER
    }

    public enum ConferenceExitedReason {
        EXITED_BY_SELF,
        EXITED_BY_ADMIN_KICK_OUT,
        EXITED_BY_SERVER_KICK_OUT,
        EXITED_BY_JOINED_ON_OTHER_DEVICE,
        EXITED_BY_KICKED_OUT_OF_LINE,
        EXITED_BY_USER_SIG_EXPIRED
    }

    public static class User implements Serializable {
        public String name;
        public String id;
        public String avatarUrl;

        @Override
        public boolean equals(Object object) {
            if (this == object) return true;
            if (!(object instanceof User)) return false;
            User user = (User) object;
            return Objects.equals(id, user.id);
        }

        @Override
        public int hashCode() {
            return Objects.hash(id);
        }
    }
}
