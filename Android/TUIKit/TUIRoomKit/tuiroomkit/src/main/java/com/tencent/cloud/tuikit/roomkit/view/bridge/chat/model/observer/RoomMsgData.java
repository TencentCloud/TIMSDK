package com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.observer;

import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.AccessRoomConstants;

import java.util.ArrayList;
import java.util.List;

public class RoomMsgData {
    private int                           version     = AccessRoomConstants.DATA_VERSION;
    private String                        businessID  = AccessRoomConstants.BUSINESS_ID_ROOM_MESSAGE;
    private String                        groupId     = "";
    private String                        messageId   = "";
    private String                        roomId      = "";
    private String                        owner       = "";
    private String                        ownerName   = "";
    private AccessRoomConstants.RoomState roomState   = AccessRoomConstants.RoomState.destroyed;
    private int                           memberCount = 0;
    private List<RoomMsgUserEntity>       userList    = new ArrayList<>();

    public String getGroupId() {
        return groupId;
    }

    public void setGroupId(String groupId) {
        this.groupId = groupId;
    }

    public String getMessageId() {
        return messageId;
    }

    public void setMessageId(String messageId) {
        this.messageId = messageId;
    }

    public String getRoomId() {
        return roomId;
    }

    public void setRoomId(String roomId) {
        this.roomId = roomId;
    }

    public String getRoomManagerId() {
        return owner;
    }

    public void setRoomManagerId(String roomManagerId) {
        this.owner = roomManagerId;
    }

    public String getRoomManagerName() {
        return ownerName;
    }

    public void setRoomManagerName(String roomManagerName) {
        this.ownerName = roomManagerName;
    }

    public AccessRoomConstants.RoomState getRoomState() {
        return roomState;
    }

    public void setRoomState(AccessRoomConstants.RoomState roomState) {
        this.roomState = roomState;
    }

    public int getMemberCount() {
        return memberCount;
    }

    public void setMemberCount(int memberCount) {
        this.memberCount = memberCount;
    }

    public List<RoomMsgUserEntity> getUserList() {
        return userList;
    }

    public void setUserList(List<RoomMsgUserEntity> userList) {
        this.userList = userList;
    }

    public RoomMsgData copy() {
        RoomMsgData data = new RoomMsgData();
        data.groupId = groupId;
        data.messageId = messageId;
        data.businessID = businessID;
        data.roomId = roomId;
        data.owner = owner;
        data.ownerName = ownerName;
        data.roomState = roomState;
        for (int i = 0; i < userList.size(); i++) {
            data.userList.add(userList.get(i));
        }
        return data;
    }
}
