package com.tencent.cloud.tuikit.roomkit.view.main.transferownercontrolpanel;

import static com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant.USER_NOT_FOUND;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_ENTER_ROOM;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.REMOTE_USER_LEAVE_ROOM;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_USER_POSITION;

import android.content.res.Configuration;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceState;
import com.tencent.cloud.tuikit.roomkit.state.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class TransferMasterViewModel implements ConferenceEventCenter.RoomEngineEventResponder,
        ConferenceEventCenter.RoomKitUIEventResponder {
    private static final String TAG = "TransferMasterViewModel";

    private ConferenceState     mConferenceState;
    private TransferMasterPanel mTransferMasterView;

    public TransferMasterViewModel(TransferMasterPanel transferMasterView) {
        mTransferMasterView = transferMasterView;
        mConferenceState = ConferenceController.sharedInstance().getConferenceState();
        subscribeEvent();
    }

    public void destroy() {
        unSubscribeEvent();
    }

    private void subscribeEvent() {
        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
        eventCenter.subscribeEngine(REMOTE_USER_ENTER_ROOM, this);
        eventCenter.subscribeEngine(REMOTE_USER_LEAVE_ROOM, this);
        eventCenter.subscribeUIEvent(CONFIGURATION_CHANGE, this);
    }

    private void unSubscribeEvent() {
        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
        eventCenter.unsubscribeEngine(REMOTE_USER_ENTER_ROOM, this);
        eventCenter.unsubscribeEngine(REMOTE_USER_LEAVE_ROOM, this);
        eventCenter.unsubscribeUIEvent(CONFIGURATION_CHANGE, this);
    }

    public void transferMasterAndExit(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        ConferenceController.sharedInstance()
                .changeUserRole(userId, TUIRoomDefine.Role.ROOM_OWNER, new TUIRoomDefine.ActionCallback() {
                    @Override
                    public void onSuccess() {
                        ConferenceController.sharedInstance().exitRoom();
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
        for (UserEntity item : mConferenceState.allUserList) {
            if (item.getUserName().contains(keyWords) || item.getUserId().contains(keyWords)) {
                searchList.add(item);
            }
        }
        return searchList;
    }

    @Override
    public void onEngineEvent(ConferenceEventCenter.RoomEngineEvent event, Map<String, Object> params) {
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
            Configuration configuration = (Configuration) params.get(ConferenceEventConstant.KEY_CONFIGURATION);
            mTransferMasterView.changeConfiguration(configuration);
        }
    }
}
