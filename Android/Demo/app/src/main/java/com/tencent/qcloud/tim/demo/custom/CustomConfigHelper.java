package com.tencent.qcloud.tim.demo.custom;

import android.content.Context;

import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.utils.BrandUtil;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;

public class CustomConfigHelper {
    private static Context mContext;

    public static void initCustom(Context context) {
        mContext = context;
        initConversationDefaultAvatar();
        initChatSettings();
    }

    public static void initConversationDefaultAvatar() {
        TUIConfig.setEnableGroupGridAvatar(true);
        TUIConfig.setDefaultAvatarImage(TUIThemeManager.getAttrResId(mContext, com.tencent.qcloud.tuikit.timcommon.R.attr.core_default_user_icon));
        TUIConfig.setDefaultGroupAvatarImage(TUIThemeManager.getAttrResId(mContext, com.tencent.qcloud.tuikit.timcommon.R.attr.core_default_group_icon_work));
    }

    public static void initChatSettings() {
        if (BrandUtil.isSamsungS9Series()) {
            TUIChatConfigs.getGeneralConfig().setUseSystemCamera(true);
        }
    }
}
