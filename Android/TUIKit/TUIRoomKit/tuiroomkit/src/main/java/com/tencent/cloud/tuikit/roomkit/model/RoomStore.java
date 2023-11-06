package com.tencent.cloud.tuikit.roomkit.model;

import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.SCREEN_STREAM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomConstant.KEY_ERROR;
import static com.tencent.cloud.tuikit.roomkit.model.RoomConstant.USER_NOT_FOUND;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.USER_CAMERA_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.USER_SCREEN_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.USER_SEND_MESSAGE_ABILITY_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.ENTER_FLOAT_WINDOW;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.EXIT_FLOAT_WINDOW;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant.KEY_REASON;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.model.entity.AudioModel;
import com.tencent.cloud.tuikit.roomkit.model.entity.TakeSeatRequestEntity;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.model.entity.VideoModel;
import com.tencent.qcloud.tuicore.TUILogin;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;

public class RoomStore {
    private static final String TAG = "RoomStore";

    public TUIRoomDefine.RoomInfo roomInfo;
    public UserModel              userModel;
    public AudioModel             audioModel;
    public VideoModel             videoModel;

    public List<UserEntity> allUserList;
    public List<UserEntity> seatUserList;

    public List<TakeSeatRequestEntity> takeSeatRequestList;

    private boolean isInFloatWindow      = false;
    private boolean isAutoShowRoomMainUi = true;

    public RoomStore() {
        Log.d(TAG, "new RoomStore instance : " + this);
        roomInfo = new TUIRoomDefine.RoomInfo();
        userModel = new UserModel();
        audioModel = new AudioModel();
        videoModel = new VideoModel();
        allUserList = new CopyOnWriteArrayList<>();
        seatUserList = new CopyOnWriteArrayList<>();
        takeSeatRequestList = new LinkedList<>();
    }

    public void addTakeSeatRequest(TUIRoomDefine.Request request) {
        UserEntity user = findUser(allUserList, request.userId);
        if (user == null) {
            Log.e(TAG, "addTakeSeatRequest user is null");
            return;
        }
        TakeSeatRequestEntity takeSeatRequestEntity =
                new TakeSeatRequestEntity(user.getUserId(), user.getUserName(), user.getAvatarUrl(), request);
        takeSeatRequestList.add(takeSeatRequestEntity);

        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_USER_POSITION, takeSeatRequestList.size() - 1);
        RoomEventCenter.getInstance()
                .notifyEngineEvent(RoomEventCenter.RoomEngineEvent.USER_TAKE_SEAT_REQUEST_ADD, map);
    }

    public void removeTakeSeatRequest(String requestId) {
        int index = -1;
        for (int i = 0; i < takeSeatRequestList.size(); i++) {
            if (TextUtils.equals(requestId, takeSeatRequestList.get(i).getRequest().requestId)) {
                index = i;
                takeSeatRequestList.remove(i);
                break;
            }
        }
        if (index == -1) {
            return;
        }
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_USER_POSITION, index);
        RoomEventCenter.getInstance()
                .notifyEngineEvent(RoomEventCenter.RoomEngineEvent.USER_TAKE_SEAT_REQUEST_REMOVE, map);
    }

    public TakeSeatRequestEntity getTakeSeatRequestEntity(String userId) {
        for (TakeSeatRequestEntity item : takeSeatRequestList) {
            if (TextUtils.equals(item.getUserId(), userId)) {
                return item;
            }
        }
        return null;
    }

    public boolean hasScreenSharingInRoom() {
        if (allUserList.isEmpty()) {
            return false;
        }
        UserEntity firstUser = allUserList.get(0);
        return firstUser.isHasVideoStream() && firstUser.getVideoStreamType() == SCREEN_STREAM;
    }

    public boolean isInFloatWindow() {
        return isInFloatWindow;
    }

    public void setInFloatWindow(boolean inFloatWindow) {
        isInFloatWindow = inFloatWindow;
        String key = isInFloatWindow ? ENTER_FLOAT_WINDOW : EXIT_FLOAT_WINDOW;
        RoomEventCenter.getInstance().notifyUIEvent(key, null);
    }

    public boolean isAutoShowRoomMainUi() {
        return isAutoShowRoomMainUi;
    }

    public void setAutoShowRoomMainUi(boolean autoShowRoomMainUi) {
        isAutoShowRoomMainUi = autoShowRoomMainUi;
    }

    public void setUserOnSeat(String userId, boolean isOnSeat) {
        for (UserEntity item : allUserList) {
            if (TextUtils.equals(userId, item.getUserId()) && item.getVideoStreamType() != SCREEN_STREAM) {
                item.setOnSeat(isOnSeat);
                break;
            }
        }
    }

    public int getTotalUserCount() {
        if (allUserList.isEmpty()) {
            return 0;
        }
        if (allUserList.get(0).getVideoStreamType() == SCREEN_STREAM) {
            return allUserList.size() - 1;
        }
        return allUserList.size();
    }

    public void remoteUserEnterRoom(TUIRoomDefine.UserInfo userInfo) {
        if (userInfo.hasScreenStream) {
            allUserList.add(0, UserEntity.toUserEntityForScreenStream(userInfo));
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_USER_POSITION, 0);
            RoomEventCenter.getInstance()
                    .notifyEngineEvent(RoomEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, map);
        }
        allUserList.add(UserEntity.toUserEntityForCameraStream(userInfo));
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_USER_POSITION, allUserList.size() - 1);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, map);
    }

    public void remoteUserLeaveRoom(String userId) {
        for (int i = 0; i < allUserList.size(); i++) {
            if (TextUtils.equals(userId, allUserList.get(i).getUserId())) {
                Map<String, Object> map = new HashMap<>();
                map.put(RoomEventConstant.KEY_USER_POSITION, i);
                RoomEventCenter.getInstance()
                        .notifyEngineEvent(RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM, map);
                allUserList.remove(i);
            }
        }
    }

    public void remoteUserTakeSeat(TUIRoomDefine.UserInfo userInfo) {
        Log.d(TAG, "remoteUserTakeSeat userId=" + userInfo.userId);
        if (TextUtils.equals(userInfo.userId, TUILogin.getUserId())) {
            userModel.isOnSeat = true;
        }
        if (userInfo.hasScreenStream) {
            boolean isUserExist = false;
            for (UserEntity item : seatUserList) {
                if (TextUtils.equals(item.getUserId(), userInfo.userId) && item.getVideoStreamType() == SCREEN_STREAM) {
                    isUserExist = true;
                    break;
                }
            }
            if (!isUserExist) {
                seatUserList.add(0, UserEntity.toUserEntityForScreenStream(userInfo));
                Map<String, Object> map = new HashMap<>();
                map.put(RoomEventConstant.KEY_USER_POSITION, 0);
                RoomEventCenter.getInstance()
                        .notifyEngineEvent(RoomEventCenter.RoomEngineEvent.REMOTE_USER_TAKE_SEAT, map);
            }
        }

        for (UserEntity item : seatUserList) {
            if (TextUtils.equals(item.getUserId(), userInfo.userId) && item.getVideoStreamType() != SCREEN_STREAM) {
                return;
            }
        }
        seatUserList.add(UserEntity.toUserEntityForCameraStream(userInfo));
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_USER_POSITION, seatUserList.size() - 1);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.REMOTE_USER_TAKE_SEAT, map);
    }

    public void remoteUserLeaveSeat(String userId) {
        Log.d(TAG, "remoteUserLeaveSeat userId=" + userId);
        if (TextUtils.equals(userId, TUILogin.getUserId())) {
            userModel.isOnSeat = false;
        }
        for (int i = 0; i < seatUserList.size(); i++) {
            if (TextUtils.equals(userId, seatUserList.get(i).getUserId())) {
                Map<String, Object> map = new HashMap<>();
                map.put(RoomEventConstant.KEY_USER_POSITION, i);
                RoomEventCenter.getInstance()
                        .notifyEngineEvent(RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_SEAT, map);
                seatUserList.remove(i);
            }
        }
    }

    public void disableUserSendingMsg(String userId, boolean disable) {
        int seatPosition = USER_NOT_FOUND;
        for (int i = 0; i < seatUserList.size(); i++) {
            if (TextUtils.equals(userId, seatUserList.get(i).getUserId())
                    && seatUserList.get(i).getVideoStreamType() != SCREEN_STREAM) {
                seatUserList.get(i).setDisableSendingMessage(disable);
                seatPosition = i;
                break;
            }
        }
        int userPosition = USER_NOT_FOUND;
        for (int i = 0; i < allUserList.size(); i++) {
            if (TextUtils.equals(userId, allUserList.get(i).getUserId())
                    && allUserList.get(i).getVideoStreamType() != SCREEN_STREAM) {
                allUserList.get(i).setDisableSendingMessage(disable);
                userPosition = i;
                break;
            }
        }

        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_SEAT_USER_POSITION, seatPosition);
        map.put(RoomEventConstant.KEY_USER_POSITION, userPosition);
        RoomEventCenter.getInstance().notifyEngineEvent(USER_SEND_MESSAGE_ABILITY_CHANGED, map);
    }

    public void updateUserAudioVolume(String userId, int volume) {
        for (UserEntity item : allUserList) {
            if (TextUtils.equals(userId, item.getUserId())) {
                item.setUserVoiceVolume(volume);
            }
        }
        for (UserEntity item : seatUserList) {
            if (TextUtils.equals(userId, item.getUserId())) {
                item.setUserVoiceVolume(volume);
            }
        }
    }

    public void updateUserAudioState(String userId, boolean hasAudio, TUIRoomDefine.ChangeReason reason) {
        int seatPosition = USER_NOT_FOUND;
        for (int i = 0; i < seatUserList.size(); i++) {
            if (TextUtils.equals(userId, seatUserList.get(i).getUserId())
                    && seatUserList.get(i).getVideoStreamType() != SCREEN_STREAM) {
                seatUserList.get(i).setHasAudioStream(hasAudio);
                seatPosition = i;
                break;
            }
        }
        int userPosition = USER_NOT_FOUND;
        for (int i = 0; i < allUserList.size(); i++) {
            if (TextUtils.equals(userId, allUserList.get(i).getUserId())
                    && allUserList.get(i).getVideoStreamType() != SCREEN_STREAM) {
                allUserList.get(i).setHasAudioStream(hasAudio);
                userPosition = i;
                break;
            }
        }
        if (TextUtils.equals(TUILogin.getUserId(), userId)) {
            audioModel.setHasAudioStream(hasAudio);
        }
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_SEAT_USER_POSITION, seatPosition);
        map.put(RoomEventConstant.KEY_USER_POSITION, userPosition);
        map.put(KEY_ERROR, reason);
        RoomEventCenter.getInstance().notifyEngineEvent(RoomEventCenter.RoomEngineEvent.USER_MIC_STATE_CHANGED, map);
    }

    public void updateUserCameraState(String userId, TUIRoomDefine.VideoStreamType streamType, boolean hasCamera,
                                      TUIRoomDefine.ChangeReason reason) {
        int seatPosition = USER_NOT_FOUND;
        for (int i = 0; i < seatUserList.size(); i++) {
            if (TextUtils.equals(userId, seatUserList.get(i).getUserId())
                    && seatUserList.get(i).getVideoStreamType() != SCREEN_STREAM) {
                seatUserList.get(i).setHasVideoStream(hasCamera);
                seatUserList.get(i).setVideoStreamType(streamType);
                seatPosition = i;
                break;
            }
        }
        int userPosition = USER_NOT_FOUND;
        for (int i = 0; i < allUserList.size(); i++) {
            if (TextUtils.equals(userId, allUserList.get(i).getUserId())
                    && allUserList.get(i).getVideoStreamType() != SCREEN_STREAM) {
                allUserList.get(i).setHasVideoStream(hasCamera);
                allUserList.get(i).setVideoStreamType(streamType);
                userPosition = i;
                break;
            }
        }
        if (TextUtils.equals(TUILogin.getUserId(), userId)) {
            videoModel.setCameraOpened(hasCamera);
        }
        Map<String, Object> map = new HashMap<>();
        map.put(RoomEventConstant.KEY_SEAT_USER_POSITION, seatPosition);
        map.put(RoomEventConstant.KEY_USER_POSITION, userPosition);
        map.put(KEY_REASON, reason);
        RoomEventCenter.getInstance().notifyEngineEvent(USER_CAMERA_STATE_CHANGED, map);
    }

    public void handleUserScreenStateChanged(String userId, boolean hasScreen) {
        Log.d(TAG, "handleUserScreenStateChanged userId=" + userId + " hasScreen=" + hasScreen);
        if (TextUtils.equals(TUILogin.getUserId(), userId)) {
            videoModel.setScreenSharing(hasScreen);
        }
        if (hasScreen) {
            UserEntity user = findUser(allUserList, userId);
            if (user == null) {
                return;
            }
            UserEntity screenUser = user.copy();
            screenUser.setHasVideoStream(true);
            screenUser.setVideoStreamType(SCREEN_STREAM);
            allUserList.add(0, screenUser);
            int seatPosition = USER_NOT_FOUND;
            UserEntity seatUser = findUser(seatUserList, userId);
            if (seatUser != null) {
                seatUserList.add(0, screenUser);
                seatPosition = 0;
            }
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_SEAT_USER_POSITION, seatPosition);
            map.put(RoomEventConstant.KEY_USER_POSITION, 0);
            RoomEventCenter.getInstance().notifyEngineEvent(USER_SCREEN_STATE_CHANGED, map);
            RoomEventCenter.getInstance()
                    .notifyEngineEvent(RoomEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, map);
        } else {
            allUserList.get(0).setHasVideoStream(false);
            if (!seatUserList.isEmpty()) {
                seatUserList.get(0).setHasVideoStream(false);
            }
            Map<String, Object> map = new HashMap<>();
            map.put(RoomEventConstant.KEY_SEAT_USER_POSITION, seatUserList.isEmpty() ? USER_NOT_FOUND : 0);
            map.put(RoomEventConstant.KEY_USER_POSITION, 0);
            RoomEventCenter.getInstance().notifyEngineEvent(USER_SCREEN_STATE_CHANGED, map);
            RoomEventCenter.getInstance()
                    .notifyEngineEvent(RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM, map);
            allUserList.remove(0);
            if (!seatUserList.isEmpty()) {
                seatUserList.remove(0);
            }
        }
    }

    private UserEntity findUser(List<UserEntity> list, String userId) {
        for (UserEntity item : list) {
            if (TextUtils.equals(userId, item.getUserId())) {
                return item;
            }
        }
        return null;
    }

    public UserEntity findUserWithCameraStream(List<UserEntity> list, String userId) {
        for (UserEntity item : list) {
            if (TextUtils.equals(userId, item.getUserId()) && item.getVideoStreamType() != SCREEN_STREAM) {
                return item;
            }
        }
        return null;
    }
}
