package com.tencent.cloud.tuikit.roomkit.videoseat.core;

import android.content.Context;

import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.videoseat.ui.TUIVideoSeatView;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;

import java.util.HashMap;
import java.util.Map;

public class TUIVideoSeatExtension implements ITUIExtension {

    public static final String OBJECT_TUI_VIDEO_SEAT = TUIVideoSeatExtension.class.getName();
    public static final String KEY_VIDEO_SEAT_VIEW   = "TUIVideoSeat";

    private TUIVideoSeatView mVideoSeatView;

    @Override
    public Map<String, Object> onGetExtensionInfo(String key, Map<String, Object> param) {
        if (OBJECT_TUI_VIDEO_SEAT.equals(key)) {
            //这个HashMap需携带返回给TUICore的View数据
            HashMap<String, Object> hashMap = new HashMap<>();
            Context context = (Context) param.get("context");
            final String roomId = (String) param.get("roomId");
            final TUIRoomEngine roomEngine = (TUIRoomEngine) param.get("roomEngine");
            mVideoSeatView = new TUIVideoSeatView(context, roomId, roomEngine);
            hashMap.put(KEY_VIDEO_SEAT_VIEW, mVideoSeatView);
            return hashMap;
        }
        return null;
    }
}
