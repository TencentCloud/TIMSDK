/**
 * Copyright (c) 2021 Tencent. All rights reserved.
 * Module:   TUIRoomKit
 * Function: Multi-person audio and video main function interface.
 */

package com.tencent.cloud.tuikit.roomkit;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.impl.TUIRoomKitImpl;

/**
 * @deprecated Please use ConferenceMainFragment for conference UI integration.
 */
@Deprecated
public abstract class TUIRoomKit {
    /**
     * 1.1 Create TUIRoomKit instance (single case mode)
     */
    @Deprecated
    public static TUIRoomKit createInstance() {
        return TUIRoomKitImpl.sharedInstance();
    }

    /**
     * 1.2 Destroy TUIRoomKit instance (singleton mode)
     */
    @Deprecated
    public static void destroyInstance() {
        TUIRoomKitImpl.destroyInstance();
    }

    /**
     * 2.1 Set personal information, including username and avatar
     *
     * @param userName  The individual's username.
     * @param avatarURL Personal avatar link.
     */
    @Deprecated
    public abstract void setSelfInfo(String userName, String avatarURL, TUIRoomDefine.ActionCallback callback);

    /**
     * 3.1 Create a room
     *
     * @param roomInfo Parameters for creating a room, including room number, room name, etc., where roomId is required, and the rest can be default values.
     */
    @Deprecated
    public abstract void createRoom(TUIRoomDefine.RoomInfo roomInfo, TUIRoomDefine.ActionCallback callback);

    /**
     * 3.2 Enter the room
     *
     * @param roomId           The room number to enter the room.
     * @param enableAudio      true Enter the room to turn on the microphone and push local audio data to the remote end. Other members can hear the local sound normally;
     *                         false When entering the room, only the microphone is turned on and local audio data is not pushed to the remote end. Other members cannot hear the local sound;
     * @param enableVideo      true Enter the room to turn on the camera and push local video data to the remote end. Other members can see the local picture normally;
     *                         false When entering the room, the camera will not be turned on and local video data will not be pushed to the remote end. Other members will not be able to see the local video;
     * @param isSoundOnSpeaker Whether to use the speaker to play sound, true to use the speaker, false to use the earpiece.
     */
    @Deprecated
    public abstract void enterRoom(String roomId, boolean enableAudio, boolean enableVideo, boolean isSoundOnSpeaker,
                                   TUIRoomDefine.GetRoomInfoCallback callback);
}
