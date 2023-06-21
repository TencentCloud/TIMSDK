package com.tencent.cloud.tuikit.roomkit.imaccess.model.manager;

import static com.tencent.cloud.tuikit.roomkit.imaccess.AccessRoomConstants.KEY_INVITE_DATA;

import android.content.Context;
import android.content.Intent;

import com.google.gson.Gson;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.TUIRoomKit;
import com.tencent.cloud.tuikit.roomkit.imaccess.model.IRoomManager;
import com.tencent.cloud.tuikit.roomkit.imaccess.model.observer.RoomMsgData;
import com.tencent.cloud.tuikit.roomkit.imaccess.view.InviteToJoinRoomActivity;
import com.tencent.cloud.tuikit.roomkit.model.entity.RoomInfo;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUILogin;

public class RoomManagerImpl implements IRoomManager {
    private TUIRoomKit mRoomKit;

    public RoomManagerImpl() {
        mRoomKit = TUIRoomKit.sharedInstance(TUILogin.getAppContext());
        mRoomKit.login(TUILogin.getSdkAppId(), TUILogin.getUserId(), TUILogin.getUserSig());
    }

    @Override
    public void raiseUi() {
        mRoomKit.raiseUi();
    }

    @Override
    public void createRoom(RoomInfo roomInfo, TUIRoomKit.RoomScene scene) {
        mRoomKit.banAutoRaiseUiOnce();
        mRoomKit.createRoom(roomInfo, scene);
    }

    @Override
    public void enterRoom(RoomInfo roomInfo) {
        mRoomKit.enterRoom(roomInfo);
    }

    @Override
    public void exitRoom() {
        RoomEngineManager.sharedInstance(TUILogin.getAppContext()).exitRoom();
    }

    @Override
    public void destroyRoom() {
        RoomEngineManager.sharedInstance(TUILogin.getAppContext()).exitRoom();
    }

    @Override
    public void changeUserRole(String userId, TUIRoomDefine.Role role, TUIRoomDefine.ActionCallback callback) {
        RoomEngineManager.sharedInstance(TUILogin.getAppContext()).getRoomEngine()
                .changeUserRole(userId, role, callback);
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
