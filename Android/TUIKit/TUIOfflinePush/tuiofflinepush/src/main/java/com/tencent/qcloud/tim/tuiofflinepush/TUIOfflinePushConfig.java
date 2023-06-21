package com.tencent.qcloud.tim.tuiofflinepush;

import android.content.Context;

public class TUIOfflinePushConfig {
    public static final String TAG = TUIOfflinePushConfig.class.getSimpleName();
    private static TUIOfflinePushConfig instance;
    private boolean isAndroidPrivateRing;

    private TUIOfflinePushConfig() {}

    public static TUIOfflinePushConfig getInstance() {
        if (instance == null) {
            instance = new TUIOfflinePushConfig();
        }
        return instance;
    }

    public static final int BRAND_HUAWEI = 2001;
    public static final int BRAND_XIAOMI = 2000;
    public static final int BRAND_OPPO = 2004;
    public static final int BRAND_VIVO = 2005;
    public static final int BRAND_MEIZU = 2003;
    public static final int BRAND_GOOLE_ELSE = 2002;
    public static final int BRAND_HONOR = 2006;

    public static final int REGISTER_TOKEN_ERROR_CODE = -1;

    public static final String EVENT_KEY_OFFLINE_MESSAGE_PRIVATE_RING = "eventKeyOfflineMessagePrivteRing";
    public static final String EVENT_SUB_KEY_OFFLINE_MESSAGE_PRIVATE_RING = "eventSubKeyOfflineMessagePrivteRing";
    public static final String OFFLINE_MESSAGE_PRIVATE_RING = "offlineMessagePrivateRing";

    private Context mContext;

    public Context getContext() {
        return this.mContext;
    }

    public void setContext(Context mContext) {
        this.mContext = mContext;
    }

    /**
     * 获取离线推送提示铃音是否为自定义铃音
     *
     * Get whether the offline push notification ringtone is a custom ringtone
     */
    public boolean isAndroidPrivateRing() {
        return isAndroidPrivateRing;
    }

    /**
     * 设置离线推送提示铃音是否为自定义铃音
     *
     * Set whether the offline push notification ringtone is a custom ringtone
     */
    public void setAndroidPrivateRing(boolean ring) {
        this.isAndroidPrivateRing = ring;
    }
}
