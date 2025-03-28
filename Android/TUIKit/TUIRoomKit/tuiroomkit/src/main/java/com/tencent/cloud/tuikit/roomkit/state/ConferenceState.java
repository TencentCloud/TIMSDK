package com.tencent.cloud.tuikit.roomkit.state;

import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.SCREEN_STREAM;
import static com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant.USER_NOT_FOUND;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.USER_CAMERA_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.USER_SCREEN_STATE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.USER_SEND_MESSAGE_ABILITY_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.ENTER_FLOAT_WINDOW;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.EXIT_FLOAT_WINDOW;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_REASON;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.state.entity.AudioModel;
import com.tencent.cloud.tuikit.roomkit.state.entity.TakeSeatRequestEntity;
import com.tencent.cloud.tuikit.roomkit.state.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.state.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.state.entity.VideoModel;
import com.tencent.qcloud.tuicore.TUILogin;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;

public class ConferenceState {
    private static final String TAG = "ConferenceState";

    public ViewState       viewState       = new ViewState();
    public SeatState       seatState       = new SeatState();
    public RoomState       roomState       = new RoomState();
    public UserState       userState       = new UserState();
    public MediaState      mediaState      = new MediaState();
    public InvitationState invitationState = new InvitationState();
    public ASRState        asrState        = new ASRState();

    public TUIRoomDefine.RoomInfo roomInfo;
    public UserModel              userModel;
    public AudioModel             audioModel;
    public VideoModel             videoModel;

    public List<UserEntity> allUserList;
    public List<UserEntity> seatUserList;

    public List<TakeSeatRequestEntity> takeSeatRequestList;

    private Class mainActivityClass;

    private boolean isInFloatWindow      = false;
    private boolean isAutoShowRoomMainUi = true;
    private boolean enableFloatChat      = true;

    public ConferenceState() {
        Log.d(TAG, "new RoomStore instance : " + this);
        roomInfo = new TUIRoomDefine.RoomInfo();
        userModel = new UserModel();
        audioModel = new AudioModel();
        videoModel = new VideoModel();
        allUserList = new CopyOnWriteArrayList<>();
        seatUserList = new CopyOnWriteArrayList<>();
        takeSeatRequestList = new CopyOnWriteArrayList<>();
    }

    public Class getMainActivityClass() {
        Log.d(TAG, "getMainActivityClass : " + mainActivityClass);
        return mainActivityClass;
    }

    public void setMainActivityClass(Class mainActivityClass) {
        Log.d(TAG, "setMainActivityClass : " + mainActivityClass);
        this.mainActivityClass = mainActivityClass;
    }

    public void handleUserRoleChanged(String userId, TUIRoomDefine.Role role) {
        if (role == TUIRoomDefine.Role.ROOM_OWNER) {
            roomInfo.ownerId = userId;
        }

        int seatPosition = USER_NOT_FOUND;
        for (int i = 0; i < seatUserList.size(); i++) {
            if (TextUtils.equals(userId, seatUserList.get(i).getUserId())
                    && seatUserList.get(i).getVideoStreamType() != SCREEN_STREAM) {
                seatUserList.get(i).setRole(role);
                seatPosition = i;
                break;
            }
        }
        int userPosition = USER_NOT_FOUND;
        for (int i = 0; i < allUserList.size(); i++) {
            if (TextUtils.equals(userId, allUserList.get(i).getUserId())
                    && allUserList.get(i).getVideoStreamType() != SCREEN_STREAM) {
                allUserList.get(i).setRole(role);
                userPosition = i;
                break;
            }
        }
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_SEAT_USER_POSITION, seatPosition);
        map.put(ConferenceEventConstant.KEY_USER_POSITION, userPosition);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.USER_ROLE_CHANGED, map);
    }

    public void addTakeSeatRequest(TUIRoomDefine.Request request) {
        String name = TextUtils.isEmpty(request.nameCard) ? request.userName : request.nameCard;
        TakeSeatRequestEntity takeSeatRequestEntity =
                new TakeSeatRequestEntity(request.userId, name, request.avatarUrl, request);
        takeSeatRequestList.add(takeSeatRequestEntity);

        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_USER_POSITION, takeSeatRequestList.size() - 1);
        ConferenceEventCenter.getInstance()
                .notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.USER_TAKE_SEAT_REQUEST_ADD, map);
    }

    public void removeTakeSeatRequestByUserId(String userId) {
        int index = -1;
        for (int i = 0; i < takeSeatRequestList.size(); i++) {
            if (TextUtils.equals(userId, takeSeatRequestList.get(i).getUserId())) {
                index = i;
                takeSeatRequestList.remove(i);
                break;
            }
        }
        if (index == -1) {
            return;
        }
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_USER_POSITION, index);
        ConferenceEventCenter.getInstance()
                .notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.USER_TAKE_SEAT_REQUEST_REMOVE, map);
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
        map.put(ConferenceEventConstant.KEY_USER_POSITION, index);
        ConferenceEventCenter.getInstance()
                .notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.USER_TAKE_SEAT_REQUEST_REMOVE, map);
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
        ConferenceEventCenter.getInstance().notifyUIEvent(key, null);
    }

    public boolean isAutoShowRoomMainUi() {
        return isAutoShowRoomMainUi;
    }

    public void setAutoShowRoomMainUi(boolean autoShowRoomMainUi) {
        isAutoShowRoomMainUi = autoShowRoomMainUi;
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
        if (findUser(allUserList, userInfo.userId) != null) {
            return;
        }
        if (TextUtils.equals(userInfo.userId, userModel.userId)) {
            userModel.initRole(userInfo.userRole);
        }
        if (userInfo.hasScreenStream) {
            allUserList.add(0, UserEntity.toUserEntityForScreenStream(userInfo));
            Map<String, Object> map = new HashMap<>();
            map.put(ConferenceEventConstant.KEY_USER_POSITION, 0);
            ConferenceEventCenter.getInstance()
                    .notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, map);
        }
        allUserList.add(UserEntity.toUserEntityForCameraStream(userInfo));
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_USER_POSITION, allUserList.size() - 1);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, map);
    }

    public void remoteUserLeaveRoom(String userId) {
        for (int i = 0; i < allUserList.size(); i++) {
            if (TextUtils.equals(userId, allUserList.get(i).getUserId())) {
                allUserList.remove(i);
                Map<String, Object> map = new HashMap<>();
                map.put(ConferenceEventConstant.KEY_USER_POSITION, i);
                ConferenceEventCenter.getInstance()
                        .notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM, map);
            }
        }
    }

    public void remoteUserTakeSeat(TUIRoomDefine.UserInfo userInfo) {
        Log.d(TAG, "remoteUserTakeSeat userId=" + userInfo.userId);
        if (TextUtils.equals(userInfo.userId, TUILogin.getUserId())) {
            userModel.setSeatStatus(UserModel.SeatStatus.ON_SEAT);
        }
        if (findUser(allUserList, userInfo.userId) == null) {
            return;
        }
        if (userInfo.hasScreenStream) {
            remoteScreenUserTakeSeat(userInfo);
        }
        remoteCameraUserTakeSeat(userInfo);
    }

    private void remoteScreenUserTakeSeat(TUIRoomDefine.UserInfo userInfo) {
        for (UserEntity item : seatUserList) {
            if (TextUtils.equals(item.getUserId(), userInfo.userId) && item.getVideoStreamType() == SCREEN_STREAM) {
                return;
            }
        }
        seatUserList.add(0, UserEntity.toUserEntityForScreenStream(userInfo));
        int userPosition = USER_NOT_FOUND;
        for (int i = 0; i < allUserList.size(); i++) {
            if (TextUtils.equals(allUserList.get(i).getUserId(), userInfo.userId)
                    && allUserList.get(i).getVideoStreamType() == SCREEN_STREAM) {
                allUserList.get(i).setOnSeat(true);
                userPosition = i;
                break;
            }
        }
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_SEAT_USER_POSITION, 0);
        map.put(ConferenceEventConstant.KEY_USER_POSITION, userPosition);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_TAKE_SEAT, map);
    }

    private void remoteCameraUserTakeSeat(TUIRoomDefine.UserInfo userInfo) {
        for (UserEntity item : seatUserList) {
            if (TextUtils.equals(item.getUserId(), userInfo.userId) && item.getVideoStreamType() != SCREEN_STREAM) {
                return;
            }
        }
        seatUserList.add(UserEntity.toUserEntityForCameraStream(userInfo));
        int userPosition = USER_NOT_FOUND;
        for (int i = 0; i < allUserList.size(); i++) {
            if (TextUtils.equals(allUserList.get(i).getUserId(), userInfo.userId)
                    && allUserList.get(i).getVideoStreamType() != SCREEN_STREAM) {
                allUserList.get(i).setOnSeat(true);
                userPosition = i;
                break;
            }
        }
        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_SEAT_USER_POSITION, seatUserList.size() - 1);
        map.put(ConferenceEventConstant.KEY_USER_POSITION, userPosition);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_TAKE_SEAT, map);
    }

    public void remoteUserLeaveSeat(String userId) {
        Log.d(TAG, "remoteUserLeaveSeat userId=" + userId);
        if (TextUtils.equals(userId, TUILogin.getUserId())) {
            userModel.setSeatStatus(UserModel.SeatStatus.OFF_SEAT);
        }
        remoteScreenUserLeaveSeat(userId);
        remoteCameraUserLeaveSeat(userId);
    }

    private void remoteScreenUserLeaveSeat(String userId) {
        int seatPosition = USER_NOT_FOUND;
        for (int i = 0; i < seatUserList.size(); i++) {
            if (seatUserList.get(i).getVideoStreamType() == SCREEN_STREAM && TextUtils.equals(userId, seatUserList.get(i).getUserId())) {
                seatPosition = i;
                break;
            }
        }
        if (seatPosition == USER_NOT_FOUND) {
            return;
        }
        int userPosition = USER_NOT_FOUND;
        for (int i = 0; i < allUserList.size(); i++) {
            if (allUserList.get(i).getVideoStreamType() == SCREEN_STREAM && TextUtils.equals(userId, allUserList.get(i).getUserId())) {
                userPosition = i;
                allUserList.get(i).setOnSeat(false);
                break;
            }
        }

        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_SEAT_USER_POSITION, seatPosition);
        map.put(ConferenceEventConstant.KEY_USER_POSITION, userPosition);
        ConferenceEventCenter.getInstance()
                .notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_SEAT, map);
        seatUserList.remove(seatPosition);
    }

    private void remoteCameraUserLeaveSeat(String userId) {
        int seatPosition = USER_NOT_FOUND;
        for (int i = 0; i < seatUserList.size(); i++) {
            if (seatUserList.get(i).getVideoStreamType() != SCREEN_STREAM && TextUtils.equals(userId, seatUserList.get(i).getUserId())) {
                seatPosition = i;
                break;
            }
        }
        if (seatPosition == USER_NOT_FOUND) {
            return;
        }
        int userPosition = USER_NOT_FOUND;
        for (int i = 0; i < allUserList.size(); i++) {
            if (allUserList.get(i).getVideoStreamType() != SCREEN_STREAM && TextUtils.equals(userId, allUserList.get(i).getUserId())) {
                userPosition = i;
                allUserList.get(i).setOnSeat(false);
                break;
            }
        }

        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_SEAT_USER_POSITION, seatPosition);
        map.put(ConferenceEventConstant.KEY_USER_POSITION, userPosition);
        ConferenceEventCenter.getInstance()
                .notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_SEAT, map);
        seatUserList.remove(seatPosition);
    }

    public void enableUserSendingMsg(String userId, boolean enable) {
        int seatPosition = USER_NOT_FOUND;
        for (int i = 0; i < seatUserList.size(); i++) {
            if (TextUtils.equals(userId, seatUserList.get(i).getUserId())
                    && seatUserList.get(i).getVideoStreamType() != SCREEN_STREAM) {
                seatUserList.get(i).setEnableSendingMessage(enable);
                seatPosition = i;
                break;
            }
        }
        int userPosition = USER_NOT_FOUND;
        for (int i = 0; i < allUserList.size(); i++) {
            if (TextUtils.equals(userId, allUserList.get(i).getUserId())
                    && allUserList.get(i).getVideoStreamType() != SCREEN_STREAM) {
                allUserList.get(i).setEnableSendingMessage(enable);
                userPosition = i;
                break;
            }
        }

        Map<String, Object> map = new HashMap<>();
        map.put(ConferenceEventConstant.KEY_SEAT_USER_POSITION, seatPosition);
        map.put(ConferenceEventConstant.KEY_USER_POSITION, userPosition);
        ConferenceEventCenter.getInstance().notifyEngineEvent(USER_SEND_MESSAGE_ABILITY_CHANGED, map);
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
        map.put(ConferenceEventConstant.KEY_SEAT_USER_POSITION, seatPosition);
        map.put(ConferenceEventConstant.KEY_USER_POSITION, userPosition);
        map.put(KEY_REASON, reason);
        ConferenceEventCenter.getInstance().notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.USER_MIC_STATE_CHANGED, map);
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
        map.put(ConferenceEventConstant.KEY_SEAT_USER_POSITION, seatPosition);
        map.put(ConferenceEventConstant.KEY_USER_POSITION, userPosition);
        map.put(KEY_REASON, reason);
        ConferenceEventCenter.getInstance().notifyEngineEvent(USER_CAMERA_STATE_CHANGED, map);
    }

    public void handleUserScreenStateChanged(String userId, boolean hasScreen) {
        Log.d(TAG, "handleUserScreenStateChanged userId=" + userId + " hasScreen=" + hasScreen);
        if (TextUtils.equals(TUILogin.getUserId(), userId)) {
            videoModel.setScreenSharing(hasScreen);
        }
        if (hasScreen) {
            UserEntity user = findUser(allUserList, userId);
            if (user == null || allUserList.get(0).getVideoStreamType() == SCREEN_STREAM) {
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
            map.put(ConferenceEventConstant.KEY_SEAT_USER_POSITION, seatPosition);
            map.put(ConferenceEventConstant.KEY_USER_POSITION, 0);
            ConferenceEventCenter.getInstance().notifyEngineEvent(USER_SCREEN_STATE_CHANGED, map);
            ConferenceEventCenter.getInstance()
                    .notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, map);
        } else {
            if (allUserList.isEmpty() || !TextUtils.equals(allUserList.get(0).getUserId(), userId)) {
                return;
            }
            allUserList.get(0).setHasVideoStream(false);
            if (!seatUserList.isEmpty()) {
                seatUserList.get(0).setHasVideoStream(false);
            }
            Map<String, Object> map = new HashMap<>();
            map.put(ConferenceEventConstant.KEY_SEAT_USER_POSITION, seatUserList.isEmpty() ? USER_NOT_FOUND : 0);
            map.put(ConferenceEventConstant.KEY_USER_POSITION, 0);
            ConferenceEventCenter.getInstance().notifyEngineEvent(USER_SCREEN_STATE_CHANGED, map);
            ConferenceEventCenter.getInstance()
                    .notifyEngineEvent(ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM, map);
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

    public void setUserNameCard(String userId, String nameCard) {
        if (allUserList.isEmpty() || TextUtils.isEmpty(userId) || TextUtils.isEmpty(nameCard)) {
            return;
        }
        for (UserEntity user : allUserList) {
            if (TextUtils.equals(user.getUserId(), userId)) {
                user.setNameCard(nameCard);
                break;
            }
        }
    }

    public void updateTakeSeatRequestUserName(String userId, String userName) {
        if (takeSeatRequestList.isEmpty() || TextUtils.isEmpty(userId) || TextUtils.isEmpty(userName)) {
            return;
        }
        for (TakeSeatRequestEntity request : takeSeatRequestList) {
            if (TextUtils.equals(request.getUserId(), userId)) {
                request.setUserName(userName);
                break;
            }
        }
    }

    public void setEnableFloatChat(boolean enable) {
        enableFloatChat = enable;
    }

    public boolean getEnableFloatChat() {
        return enableFloatChat;
    }
}
