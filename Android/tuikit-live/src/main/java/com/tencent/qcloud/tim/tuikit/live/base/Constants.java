package com.tencent.qcloud.tim.tuikit.live.base;

public class Constants {
    public static final int RETURN_FAIL = -1;

    public static final String ROOM_NAME          = "room_name";
    public static final String GROUP_ID           = "group_id";
    public static final String USE_CDN            = "use_cdn";
    public static final String USE_CDN_PLAY       = "use_cdn_play";
    public static final String ROOM_TITLE         = "room_title";
    public static final String CDN_URL            = "cdn_url";
    public static final String PUSHER_NAME        = "pusher_name";
    public static final String COVER_PIC          = "cover_pic";
    public static final String PUSHER_AVATAR      = "pusher_avatar";
    public static final String ROOM_ID            = "room_id";
    public static final String ANCHOR_ID          = "anchor_id";
    public static final String ANCHOR_ID_LIST     = "anchor_id_list";


    /**
     * 直播端右下角listview显示type
     */
    public static final int TEXT_TYPE                 = 0;
    public static final int MEMBER_ENTER              = 1;
    public static final int MEMBER_EXIT               = 2;
    public static final int PRAISE                    = 3;
    public static final int IMCMD_PRAISE              = 4;   // 点赞消息
    public static final int IMCMD_DANMU               = 5;   // 弹幕消息
    public static final int IMCMD_GIFT                = 6;   // 礼物消息
    public static final int REQUEST_LINK_MIC_TIME_OUT = 60;  // 请求 连麦/PK 的超时时间
    public static final int REQUEST_PK_TIME_OUT       = 15;  // 请求 PK 的超时时间
    public static final int MAX_LINK_MIC_SIZE         = 3;   // 最大连麦人数
    public static final int WINDOW_MODE_FULL          = 1;   // 全屏播放
    public static final int WINDOW_MODE_FLOAT         = 2;   // 悬浮窗播放
}
