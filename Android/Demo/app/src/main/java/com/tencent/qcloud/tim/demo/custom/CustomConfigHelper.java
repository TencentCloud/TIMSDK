package com.tencent.qcloud.tim.demo.custom;

import android.content.Context;
import com.tencent.qcloud.tim.demo.utils.BrandUtil;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;

public class CustomConfigHelper {
    private static Context mContext;

    public static void initCustom(Context context) {
        mContext = context;
        initChatSettings();
    }

    public static void initChatSettings() {
        if (BrandUtil.isSamsungS9Series()) {
            TUIChatConfigs.getConfigs().getGeneralConfig().setUseSystemCamera(true);
        }
    }
}
