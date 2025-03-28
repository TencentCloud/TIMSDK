package com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.observer;

import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.Role.ROOM_OWNER;
import static com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant.KEY_ERROR;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_CREATE_ROOM;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_DESTROY_ROOM;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_ENTER_ROOM;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.LOCAL_USER_EXIT_ROOM;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomObserver;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.AccessRoomConstants;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.IRoomCallback;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.manager.RoomMsgManager;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.qcloud.tuicore.TUILogin;

import java.util.List;
import java.util.Map;

public class RoomObserver extends TUIRoomObserver implements ConferenceEventCenter.RoomEngineEventResponder {
    private static final String         TAG = "RoomObserver";
    private              RoomMsgManager mRoomMsgManager;
    private              IRoomCallback  mRoomCallback;

    private RoomMsgData mRoomMsgData;

    public RoomObserver(IRoomCallback callback) {
        mRoomCallback = callback;
        mRoomMsgManager = new RoomMsgManager();
    }

    public void destroyRoomObserver() {
        mRoomMsgManager.destroyRoomMsgManager();
    }

    public void initMsgData(String roomId) {
        mRoomMsgData = new RoomMsgData();
        mRoomMsgData.setRoomId(roomId);
        mRoomMsgData.setRoomManagerId(TUILogin.getUserId());
        mRoomMsgData.setRoomManagerName(TUILogin.getNickName());
        mRoomMsgData.setRoomState(AccessRoomConstants.RoomState.creating);
        mRoomMsgManager.sendGroupRoomMessage(mRoomMsgData);
    }

    public void setMsgData(RoomMsgData roomMsgData) {
        mRoomMsgData = roomMsgData;
    }

    public RoomMsgData getRoomMsgData() {
        return mRoomMsgData;
    }

    public void registerObserver() {
        ConferenceController.sharedInstance(TUILogin.getAppContext()).getRoomEngine().addObserver(this);
        ConferenceEventCenter.getInstance().subscribeEngine(LOCAL_USER_CREATE_ROOM, this);
        ConferenceEventCenter.getInstance().subscribeEngine(LOCAL_USER_ENTER_ROOM, this);
        ConferenceEventCenter.getInstance().subscribeEngine(LOCAL_USER_EXIT_ROOM, this);
        ConferenceEventCenter.getInstance().subscribeEngine(LOCAL_USER_DESTROY_ROOM, this);
    }

    public void unregisterObserver() {
        ConferenceController.sharedInstance(TUILogin.getAppContext()).getRoomEngine().removeObserver(this);
        ConferenceEventCenter.getInstance().unsubscribeEngine(LOCAL_USER_CREATE_ROOM, this);
        ConferenceEventCenter.getInstance().unsubscribeEngine(LOCAL_USER_ENTER_ROOM, this);
        ConferenceEventCenter.getInstance().unsubscribeEngine(LOCAL_USER_EXIT_ROOM, this);
        ConferenceEventCenter.getInstance().unsubscribeEngine(LOCAL_USER_DESTROY_ROOM, this);
    }

    public boolean isRoomOwner() {
        if (mRoomMsgData == null) {
            return false;
        }
        String selfId = TUILogin.getUserId();
        return selfId.equals(mRoomMsgData.getRoomManagerId());
    }

    public RoomMsgUserEntity getRoomOwnerVolunteer() {
        if (mRoomMsgData == null) {
            return null;
        }
        String selfId = TUILogin.getUserId();
        for (RoomMsgUserEntity item : mRoomMsgData.getUserList()) {
            if (item.getUserId().equals(selfId)) {
                continue;
            }
            return item;
        }
        return null;
    }

    private long mNextSequence = 0L;

    private void getUserList() {
        Log.d(TAG, "getUserList");
        mRoomMsgData.getUserList().clear();
        ConferenceController.sharedInstance(TUILogin.getAppContext()).getRoomEngine()
                .getUserList(mNextSequence, new TUIRoomDefine.GetUserListCallback() {
                    @Override
                    public void onSuccess(TUIRoomDefine.UserListResult userListResult) {
                        Log.d(TAG, "getUserList onSuccess nextSequence=" + userListResult.nextSequence);
                        mNextSequence = userListResult.nextSequence;
                        addNewFreeUsers(userListResult.userInfoList);
                        if (mNextSequence != 0) {
                            getUserList();
                        } else {
                            mRoomMsgManager.updateGroupRoomMessage(mRoomMsgData);
                            mRoomCallback.onFetchUserListComplete(mRoomMsgData.getRoomId());
                        }
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String s) {
                        Log.d(TAG, "getUserList onError error=" + error + "  s=" + s);
                    }
                });
    }

    private void addNewFreeUsers(List<TUIRoomDefine.UserInfo> userInfoList) {
        for (TUIRoomDefine.UserInfo item : userInfoList) {
            Log.d(TAG, "addNewFreeUsers userName=" + item.userName + " userId=" + item.userId + " avatarUrl="
                    + item.avatarUrl);
            RoomMsgUserEntity userEntity = new RoomMsgUserEntity(item.userId, item.userName, item.avatarUrl);
            mRoomMsgData.getUserList().add(userEntity);
            mRoomMsgManager.updateGroupRoomMessage(mRoomMsgData);
        }
    }

    public void updateMsgForRoomStateChanged(AccessRoomConstants.RoomState state) {
        mRoomMsgData.setRoomState(state);
        mRoomMsgManager.updateGroupRoomMessage(mRoomMsgData, true);
    }

    @Override
    public void onUserInfoChanged(TUIRoomDefine.UserInfo userInfo, List<TUIRoomDefine.UserInfoModifyFlag> modifyFlag) {
        super.onUserInfoChanged(userInfo, modifyFlag);
        if (mRoomMsgData == null) {
            return;
        }
        Log.d(TAG, "onUserInfoChanged userId=" + userInfo.userId + " userRole=" + userInfo.userRole);
        if (userInfo.userRole == ROOM_OWNER) {
            mRoomMsgData.setRoomManagerId(userInfo.userId);
            mRoomMsgData.setRoomManagerName(TextUtils.isEmpty(userInfo.nameCard) ? userInfo.userName : userInfo.nameCard);
            mRoomMsgManager.updateGroupRoomMessage(mRoomMsgData);
        }
    }

    @Override
    public void onRemoteUserEnterRoom(String roomId, TUIRoomDefine.UserInfo userInfo) {
        super.onRemoteUserEnterRoom(roomId, userInfo);
        if (mRoomMsgData == null) {
            return;
        }
        Log.d(TAG, "onRemoteUserEnterRoom roomId=" + roomId + " userName=" + userInfo.userName + " userId="
                + userInfo.userId);
        boolean isUserAdded = false;
        for (RoomMsgUserEntity item : mRoomMsgData.getUserList()) {
            if (item.getUserId().equals(userInfo.userId)) {
                isUserAdded = true;
                break;
            }
        }
        if (isUserAdded) {
            Log.w(TAG, "onRemoteUserEnterRoom isUserAdded=true roomId=" + roomId + " userName=" + userInfo.userName
                    + " userId=" + userInfo.userId);
            return;
        }
        RoomMsgUserEntity userEntity = new RoomMsgUserEntity(userInfo.userId, userInfo.userName, userInfo.avatarUrl);
        mRoomMsgData.getUserList().add(userEntity);
        mRoomMsgManager.updateGroupRoomMessage(mRoomMsgData);
    }

    @Override
    public void onRemoteUserLeaveRoom(String roomId, TUIRoomDefine.UserInfo userInfo) {
        super.onRemoteUserLeaveRoom(roomId, userInfo);
        if (mRoomMsgData == null) {
            return;
        }
        Log.d(TAG, "onRemoteUserLeaveRoom roomId=" + roomId + " userName=" + userInfo.userName + " userId="
                + userInfo.userId);
        for (RoomMsgUserEntity item : mRoomMsgData.getUserList()) {
            if (item.getUserId().equals(userInfo.userId)) {
                mRoomMsgData.getUserList().remove(item);
                break;
            }
        }
        mRoomMsgManager.updateGroupRoomMessage(mRoomMsgData);
    }

    @Override
    public void onEngineEvent(ConferenceEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        Log.d(TAG, "onEngineEvent event=" + event);
        switch (event) {
            case LOCAL_USER_CREATE_ROOM:
                handleLocalUserCreateRoom(params);
                break;

            case LOCAL_USER_ENTER_ROOM:
                handleLocalUserEnterRoom(params);
                break;

            case LOCAL_USER_EXIT_ROOM:
                handleLocalUserExitRoom();
                break;

            case LOCAL_USER_DESTROY_ROOM:
                handleLocalUserDestroyRoom(params);
                break;

            default:
                Log.w(TAG, "onEngineEvent un handle event : " + event);
                break;
        }
    }

    private void handleLocalUserCreateRoom(Map<String, Object> params) {
        AccessRoomConstants.RoomResult result =
                params.get(KEY_ERROR) == TUICommonDefine.Error.SUCCESS ? AccessRoomConstants.RoomResult.SUCCESS :
                        AccessRoomConstants.RoomResult.FAILED;
        Log.d(TAG, "handleLocalUserCreateRoom result=" + result);
        if (result == AccessRoomConstants.RoomResult.SUCCESS) {
            mRoomMsgData.setRoomState(AccessRoomConstants.RoomState.created);
            mRoomMsgManager.updateGroupRoomMessage(mRoomMsgData);
        } else {
            updateMsgForRoomStateChanged(AccessRoomConstants.RoomState.destroyed);
        }
        mRoomCallback.onCreateRoom(mRoomMsgData.getRoomId(), result);
    }

    private void handleLocalUserEnterRoom(Map<String, Object> params) {
        AccessRoomConstants.RoomResult result =
                params.get(KEY_ERROR) == TUICommonDefine.Error.SUCCESS ? AccessRoomConstants.RoomResult.SUCCESS :
                        AccessRoomConstants.RoomResult.FAILED;
        Log.d(TAG, "handleLocalUserEnterRoom result=" + result);
        if (result == AccessRoomConstants.RoomResult.SUCCESS) {
            getUserList();
        } else {
            updateMsgForRoomStateChanged(AccessRoomConstants.RoomState.destroyed);
        }
        mRoomCallback.onEnterRoom(mRoomMsgData.getRoomId(), result);
    }

    private void handleLocalUserExitRoom() {
        Log.d(TAG, "handleLocalUserExitRoom");
        mRoomCallback.onExitRoom(mRoomMsgData.getRoomId());
    }

    private void handleLocalUserDestroyRoom(Map<String, Object> params) {
        AccessRoomConstants.RoomResult result =
                params.get(KEY_ERROR) == TUICommonDefine.Error.SUCCESS ? AccessRoomConstants.RoomResult.SUCCESS :
                        AccessRoomConstants.RoomResult.FAILED;
        Log.d(TAG, "handleLocalUserDestroyRoom result=" + result);
        updateMsgForRoomStateChanged(AccessRoomConstants.RoomState.destroyed);
        mRoomCallback.onDestroyRoom(mRoomMsgData.getRoomId());
    }
}
