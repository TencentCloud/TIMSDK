package com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.manager;

import static com.tencent.cloud.tuikit.roomkit.view.bridge.chat.AccessRoomConstants.KEY_INVITE_DATA;

import android.content.Context;
import android.content.Intent;

import com.google.gson.Gson;
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.TUIRoomKit;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.IRoomManager;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.observer.RoomMsgData;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.view.InviteToJoinRoomActivity;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUILogin;

public class RoomManagerImpl implements IRoomManager {
    private TUIRoomKit mRoomKit;

    public RoomManagerImpl() {
        mRoomKit = TUIRoomKit.createInstance();
    }

    @Override
    public void enableAutoShowRoomMainUi(boolean enable) {
        ConferenceController.sharedInstance(TUILogin.getAppContext()).enableAutoShowRoomMainUi(enable);
    }

    @Override
    public void createRoom(String roomId, boolean isOpenMic, boolean isOpenCamera, boolean isUseSpeaker) {
        TUIRoomDefine.RoomInfo engineRoomInfo = new TUIRoomDefine.RoomInfo();
        engineRoomInfo.roomId = roomId;
        mRoomKit.createRoom(engineRoomInfo, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                mRoomKit.enterRoom(roomId, isOpenMic, isOpenCamera, isUseSpeaker, null);
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
            }
        });
    }

    @Override
    public void enterRoom(String roomId, boolean isOpenMic, boolean isOpenCamera, boolean isUseSpeaker) {
        mRoomKit.enterRoom(roomId, isOpenMic, isOpenCamera, isUseSpeaker, null);
    }

    @Override
    public void exitRoom() {
        ConferenceController.sharedInstance().exitRoom();
    }

    @Override
    public void destroyRoom() {
        ConferenceController.sharedInstance().destroyRoom(null);
    }

    @Override
    public void changeUserRole(String userId, TUIRoomDefine.Role role, TUIRoomDefine.ActionCallback callback) {
        ConferenceController.sharedInstance().changeUserRole(userId, role, callback);
    }

    @Override
    public void inviteOtherMembersToJoin(RoomMsgData roomMsgData, TUIRoomDefine.LoginUserInfo inviteUser) {
        InviteJoinData data = new InviteJoinData(roomMsgData, inviteUser);
        Gson gson = new Gson();
        String content = gson.toJson(data);
        Context context = TUIConfig.getAppContext();
        if (context == null) {
            return;
        }
        Intent intent = new Intent(context, InviteToJoinRoomActivity.class);
        intent.putExtra(KEY_INVITE_DATA, content);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }
}
