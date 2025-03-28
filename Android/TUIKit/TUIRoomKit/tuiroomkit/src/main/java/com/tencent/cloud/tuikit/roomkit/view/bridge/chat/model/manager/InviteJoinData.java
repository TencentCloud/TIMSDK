package com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.manager;

import static com.tencent.cloud.tuikit.roomkit.view.bridge.chat.AccessRoomConstants.DATA_VERSION;
import static com.tencent.cloud.tuikit.roomkit.view.bridge.chat.AccessRoomConstants.ROOM_INVITE_SINGLING;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.observer.RoomMsgData;

public class InviteJoinData {
    public String     platform   = "Android";
    public int        version    = DATA_VERSION;
    public String     businessID = ROOM_INVITE_SINGLING;
    public String     roomId     = "";
    public String     extInfo    = "";
    public MyRoomData data;


    public InviteJoinData(RoomMsgData roomMsgData, TUIRoomDefine.LoginUserInfo inviter) {
        roomId = roomMsgData.getRoomId();
        data = new MyRoomData(roomMsgData, inviter);
    }

    public class MyRoomData {
        public RoomMsgData                 roomInfo;
        public TUIRoomDefine.LoginUserInfo inviter;

        public MyRoomData(RoomMsgData roomMsgData, TUIRoomDefine.LoginUserInfo inviter) {
            this.roomInfo = roomMsgData;
            this.inviter = inviter;
        }
    }
}
