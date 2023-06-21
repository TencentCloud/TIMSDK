package com.tencent.cloud.tuikit.roomkit.viewmodel;

import android.content.Context;
import android.content.res.Configuration;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.component.TransferMasterView;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TransferMasterViewModel implements RoomEventCenter.RoomEngineEventResponder,
        RoomEventCenter.RoomKitUIEventResponder {
    private static final String TAG = "TransferMasterViewModel";

    private static final long USER_LIST_NEXT_SEQUENCE = 100L;

    private RoomStore          mRoomStore;
    private TUIRoomEngine      mRoomEngine;
    private TransferMasterView mTransferMasterView;

    private List<UserModel>        mUserModelList;
    private Map<String, UserModel> mUserModelMap;

    public TransferMasterViewModel(Context context, TransferMasterView transferMasterView) {
        mTransferMasterView = transferMasterView;
        RoomEngineManager engineManager = RoomEngineManager.sharedInstance(context);
        mRoomStore = engineManager.getRoomStore();
        mRoomEngine = engineManager.getRoomEngine();
        mUserModelList = new ArrayList<>();
        mUserModelMap = new HashMap<>();
        initUserList();
        subscribeEvent();
    }

    private void subscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM, this);
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public void destroy() {
        unSubscribeEvent();
    }

    private void unSubscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public void transferMaster(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        mRoomEngine.changeUserRole(userId, TUIRoomDefine.Role.ROOM_OWNER, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                mRoomStore.userModel.role = TUIRoomDefine.Role.GENERAL_USER;
                RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_MEETING, null);
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                Log.e(TAG, "changeUserRole error,code:" + error + ",msg:" + s);
            }
        });
    }

    private void addMemberEntity(UserModel userModel) {
        if (userModel == null) {
            return;
        }
        if (TUIRoomDefine.Role.ROOM_OWNER.equals(userModel.role)) {
            return;
        }
        if (findUserModel(userModel.userId) != null) {
            return;
        }
        mUserModelList.add(userModel);
        mUserModelMap.put(userModel.userId, userModel);
        mTransferMasterView.addItem(userModel);
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
            mTransferMasterView.removeItem(userModel);
        }
    }

    private void initUserList() {
        mRoomEngine.getUserList(USER_LIST_NEXT_SEQUENCE, new TUIRoomDefine.GetUserListCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.UserListResult userListResult) {
                for (TUIRoomDefine.UserInfo userInfo : userListResult.userInfoList) {
                    UserModel userModel = new UserModel();
                    userModel.userId = userInfo.userId;
                    userModel.userName = userInfo.userName;
                    userModel.userAvatar = userInfo.avatarUrl;
                    userModel.role = userInfo.userRole;
                    addMemberEntity(userModel);
                }
                if (userListResult.nextSequence != 0) {
                    initUserList();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                Log.e(TAG, "getUserList error,code:" + error + ",msg:" + s);
            }
        });
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

    private UserModel findUserModelByName(String userName) {
        if (TextUtils.isEmpty(userName)) {
            return null;
        }
        for (UserModel model : mUserModelList) {
            if (model == null) {
                continue;
            }
            if (userName.equals(model.userName)) {
                return model;
            }
        }
        return null;
    }

    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
            case REMOTE_USER_ENTER_ROOM:
                onRemoteUserEnterRoom(params);
                break;
            case REMOTE_USER_LEAVE_ROOM:
                onRemoteUserLeaveRoom(params);
                break;
            default:
                break;
        }
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
        userModel.role = userInfo.userRole;
        addMemberEntity(userModel);
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

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE.equals(key)
                && params != null && mTransferMasterView.isShowing()) {
            Configuration configuration = (Configuration) params.get(RoomEventConstant.KEY_CONFIGURATION);
            mTransferMasterView.changeConfiguration(configuration);
        }
    }
}
