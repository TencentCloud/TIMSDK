package com.tencent.cloud.tuikit.roomkit;

import android.content.Context;

import com.tencent.cloud.tuikit.roomkit.model.entity.RoomInfo;
import com.tencent.cloud.tuikit.roomkit.model.TUIRoomKitImpl;

public abstract class TUIRoomKit {
    public enum RoomScene {
        MEETING,
        LIVE
    }

    public static TUIRoomKit sharedInstance(Context context) {
        return TUIRoomKitImpl.sharedInstance(context);
    }

    public abstract void login(int sdkAppId, String userId, String userSig);

    public abstract void logout();

    public abstract void setSelfInfo(String userName, String avatarURL);

    public abstract void enterPrepareView(boolean enablePreview);

    public abstract void createRoom(RoomInfo roomInfo, RoomScene scene);

    public abstract void enterRoom(RoomInfo roomInfo);

    public abstract void addListener(TUIRoomKitListener listener);

    public abstract void removeListener(TUIRoomKitListener listener);

    public abstract void banAutoRaiseUiOnce();

    public abstract void raiseUi();
}
