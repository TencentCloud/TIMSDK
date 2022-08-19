package com.tencent.qcloud.tim.tuiofflinepush;

import android.content.Context;

public class TUIOfflinePushConfig {
    public static final String TAG = TUIOfflinePushConfig.class.getSimpleName();
    private static TUIOfflinePushConfig instance;

    private TUIOfflinePushConfig() {

    }

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

    private Context mContext;

    public Context getContext() {
        return this.mContext;
    }

    public void setContext(Context mContext) {
        this.mContext = mContext;
    }
}
