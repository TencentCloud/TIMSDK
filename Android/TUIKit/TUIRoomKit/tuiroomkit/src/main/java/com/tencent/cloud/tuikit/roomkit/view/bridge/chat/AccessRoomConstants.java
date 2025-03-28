package com.tencent.cloud.tuikit.roomkit.view.bridge.chat;

public interface AccessRoomConstants {

    String KEY_INVITE_DATA = "KEY_INVITE_DATA";

    String BUSINESS_ID_ROOM_MESSAGE = "group_room_message";

    String ROOM_INVITE_SINGLING = "ROOM_INVITE_ACTION";

    int DATA_VERSION = 1;

    int MSG_MAX_SHOW_MEMBER_COUNT = 5;

    enum RoomState {
        creating,
        created,
        destroying,
        destroyed
    }

    enum SelfRoomStatus {
        NO_IN_ROOM,
        JOINING_ROOM,
        JOINED_ROOM,
        LEAVING_ROOM
    }

    enum RoomResult {
        SUCCESS,
        FAILED
    }
}
