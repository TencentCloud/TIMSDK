package com.tencent.cloud.tuikit.roomkit.imaccess;

public interface AccessRoomConstants {

    String KEY_INVITE_DATA = "KEY_INVITE_DATA";

    String BUSINESS_ID_ROOM_MESSAGE = "group_room_message";

    String ROOM_INVITE_SINGLING = "ROOM_INVITE_ACTION";

    String ROOM_SP_FILE_NAME = "ROOM_SP_FILE_NAME";
    String SP_ROOM_ID = "ROOM_ID";

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
