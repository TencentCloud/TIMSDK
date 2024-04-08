package com.tencent.cloud.tuikit.roomkit.viewmodel;

import static com.tencent.cloud.tuikit.roomkit.model.RoomConstant.USER_NOT_FOUND;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant.KEY_USER_POSITION;

import android.content.res.Configuration;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.TransferOwnerControlPanel.TransferMasterPanel;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class TransferMasterViewModel implements RoomEventCenter.RoomEngineEventResponder,
        RoomEventCenter.RoomKitUIEventResponder {
    private static final String TAG = "TransferMasterViewModel";

    private RoomStore           mRoomStore;
    private TransferMasterPanel mTransferMasterView;

    public TransferMasterViewModel(TransferMasterPanel transferMasterView) {
        mTransferMasterView = transferMasterView;
        mRoomStore = RoomEngineManager.sharedInstance().getRoomStore();
        subscribeEvent();
    }

    public void destroy() {
        unSubscribeEvent();
    }

    private void subscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.subscribeEngine(REMOTE_USER_ENTER_ROOM, this);
        eventCenter.subscribeEngine(REMOTE_USER_LEAVE_ROOM, this);
        eventCenter.subscribeUIEvent(CONFIGURATION_CHANGE, this);
    }

    private void unSubscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.unsubscribeEngine(REMOTE_USER_ENTER_ROOM, this);
        eventCenter.unsubscribeEngine(REMOTE_USER_LEAVE_ROOM, this);
        eventCenter.unsubscribeUIEvent(CONFIGURATION_CHANGE, this);
    }

    public void transferMaster(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        RoomEngineManager.sharedInstance()
                .changeUserRole(userId, TUIRoomDefine.Role.ROOM_OWNER, new TUIRoomDefine.ActionCallback() {
                    @Override
                    public void onSuccess() {
                        RoomEngineManager.sharedInstance().exitRoom(null);
                    }

                    @Override
                    public void onError(TUICommonDefine.Error error, String s) {
                        Log.e(TAG, "changeUserRole error,code:" + error + ",msg:" + s);
                    }
                });
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

    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
            case REMOTE_USER_ENTER_ROOM:
                handleRemoteUserEnterRoom(params);
                break;

            case REMOTE_USER_LEAVE_ROOM:
                handleRemoteUserLeaveRoom(params);
                break;

            default:
                break;
        }
    }

    private void handleRemoteUserEnterRoom(Map<String, Object> params) {
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        mTransferMasterView.onNotifyUserEnter(position);
    }

    private void handleRemoteUserLeaveRoom(Map<String, Object> params) {
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        mTransferMasterView.onNotifyUserExit(position);
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (CONFIGURATION_CHANGE.equals(key)
                && params != null && mTransferMasterView.isShowing()) {
            Configuration configuration = (Configuration) params.get(RoomEventConstant.KEY_CONFIGURATION);
            mTransferMasterView.changeConfiguration(configuration);
        }
    }
}
