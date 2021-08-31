package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.room;

import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base.TXRoomInfo;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base.TXUserInfo;

public interface ITXRoomServiceDelegate {
    void onRoomInfoChange(TXRoomInfo txRoomInfo);

    void onRoomDestroy(String roomId);

    void onRoomAnchorEnter(String userId);

    void onRoomAnchorExit(String userId);

    void onRoomAudienceEnter(TXUserInfo userInfo);

    void onRoomAudienceExit(TXUserInfo userInfo);

    void onRoomStreamAvailable(String userId);

    void onRoomStreamUnavailable(String userId);

    void onRoomRequestJoinAnchor(TXUserInfo userInfo, String reason);

    void onRoomKickoutJoinAnchor();

    void onRoomRequestRoomPK(TXUserInfo userInfo);

    void onRoomResponseRoomPK(String roomId, String streamId, TXUserInfo userInfo);

    void onAnchorCancelRequestRoomPK(String userId);

    void onAnchorRequestRoomPKTimeout(String userId);

    void onAudienceRequestJoinAnchorTimeout(String userId);

    void onAudienceCancelRequestJoinAnchor(String userId);

    void onRoomQuitRoomPk();

    void onRoomRecvRoomTextMsg(String roomId, String message, TXUserInfo userInfo);

    void onRoomRecvRoomCustomMsg(String roomId, String cmd, String message, TXUserInfo userInfo);
}

