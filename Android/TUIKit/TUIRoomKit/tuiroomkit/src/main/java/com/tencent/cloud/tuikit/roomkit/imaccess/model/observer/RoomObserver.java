package com.tencent.cloud.tuikit.roomkit.imaccess.model.observer;

import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.Role.ROOM_OWNER;

import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomObserver;
import com.tencent.cloud.tuikit.roomkit.TUIRoomKit;
import com.tencent.cloud.tuikit.roomkit.TUIRoomKitListener;
import com.tencent.cloud.tuikit.roomkit.imaccess.AccessRoomConstants;
import com.tencent.cloud.tuikit.roomkit.imaccess.model.IRoomCallback;
import com.tencent.cloud.tuikit.roomkit.imaccess.model.manager.RoomMsgManager;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.qcloud.tuicore.TUILogin;

import java.util.List;

public class RoomObserver extends TUIRoomObserver implements TUIRoomKitListener {
    private static final String TAG = "RoomObserver";
    private RoomMsgManager mRoomMsgManager;
    private IRoomCallback  mRoomCallback;

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
        RoomEngineManager.sharedInstance(TUILogin.getAppContext()).getRoomEngine().addObserver(this);
        TUIRoomKit.sharedInstance(TUILogin.getAppContext()).addListener(this);
    }

    public void unregisterObserver() {
        RoomEngineManager.sharedInstance(TUILogin.getAppContext()).getRoomEngine().removeObserver(this);
        TUIRoomKit.sharedInstance(TUILogin.getAppContext()).removeListener(this);
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

    @Override
    public void onLogin(int code, String message) {
        Log.d(TAG, "onLogin code=" + code + " message=" + message);
        if (code == 0) {
            mRoomCallback.onLoginSuccess();
        } else {
            Log.e(TAG, "onLogin code=" + code + " message=" + message);
        }
    }

    @Override
    public void onRoomCreate(int code, String message) {
        Log.d(TAG, "onRoomCreate code=" + code + " message=" + message);
        AccessRoomConstants.RoomResult result =
                code == 0 ? AccessRoomConstants.RoomResult.SUCCESS : AccessRoomConstants.RoomResult.FAILED;
        if (result == AccessRoomConstants.RoomResult.SUCCESS) {
            mRoomMsgData.setRoomState(AccessRoomConstants.RoomState.created);
            mRoomMsgManager.updateGroupRoomMessage(mRoomMsgData);
        } else {
            updateMsgForRoomStateChanged(AccessRoomConstants.RoomState.destroyed);
        }
        mRoomCallback.onCreateRoom(mRoomMsgData.getRoomId(), result);
    }

    @Override
    public void onRoomEnter(int code, String message) {
        Log.d(TAG, "onRoomEnter code=" + code + " message=" + message);
        AccessRoomConstants.RoomResult result =
                code == 0 ? AccessRoomConstants.RoomResult.SUCCESS : AccessRoomConstants.RoomResult.FAILED;
        if (result == AccessRoomConstants.RoomResult.SUCCESS) {
            getUserList();
        } else {
            updateMsgForRoomStateChanged(AccessRoomConstants.RoomState.destroyed);
        }
        mRoomCallback.onEnterRoom(mRoomMsgData.getRoomId(), result);
    }

    private long mNextSequence = 0L;

    private void getUserList() {
        Log.d(TAG, "getUserList");
        mRoomMsgData.getUserList().clear();
        RoomEngineManager.sharedInstance(TUILogin.getAppContext()).getRoomEngine()
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

    @Override
    public void onDestroyRoom() {
        Log.d(TAG, "onDestroyRoom");
        updateMsgForRoomStateChanged(AccessRoomConstants.RoomState.destroyed);
        mRoomCallback.onDestroyRoom(mRoomMsgData.getRoomId());
    }

    public void updateMsgForRoomStateChanged(AccessRoomConstants.RoomState state) {
        mRoomMsgData.setRoomState(state);
        mRoomMsgManager.updateGroupRoomMessage(mRoomMsgData, true);
    }

    @Override
    public void onExitRoom() {
        Log.d(TAG, "onExitRoom");
        mRoomCallback.onExitRoom(mRoomMsgData.getRoomId());
    }

    @Override
    public void onUserRoleChanged(String userId, TUIRoomDefine.Role userRole) {
        super.onUserRoleChanged(userId, userRole);
        if (mRoomMsgData == null) {
            return;
        }
        Log.d(TAG, "onUserRoleChanged userId=" + userId + " userRole=" + userRole);
        if (userRole == ROOM_OWNER) {
            mRoomMsgData.setRoomManagerId(userId);
            mRoomMsgData.setRoomManagerName(TUILogin.getNickName());
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
}
