package com.tencent.qcloud.tim.uikit.live.livemsg;

public class TUILiveOnClickListenerManager {
    public static final String TAG = TUILiveOnClickListenerManager.class.getSimpleName();

    public interface GroupLiveHandler {
        boolean startGroupLive(String groupId);
    }

    private static GroupLiveHandler groupLiveHandler;

    public static void setGroupLiveHandler(GroupLiveHandler outsideGroupLiveHandler) {
        groupLiveHandler = outsideGroupLiveHandler;
    }

    private static LiveGroupMessageClickListener liveGroupMessageClickListener;

    public static void setLiveGroupMessageClickListener(LiveGroupMessageClickListener clickListener) {
        liveGroupMessageClickListener = clickListener;
    }

    public static GroupLiveHandler getGroupLiveHandler() {
        return groupLiveHandler;
    }

    public static LiveGroupMessageClickListener getLiveGroupMessageClickListener() {
        return liveGroupMessageClickListener;
    }
}
