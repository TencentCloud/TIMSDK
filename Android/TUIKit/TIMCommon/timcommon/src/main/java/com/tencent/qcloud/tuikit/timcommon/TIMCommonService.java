package com.tencent.qcloud.tuikit.timcommon;

import android.content.Context;
import android.text.TextUtils;

import com.google.auto.service.AutoService;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerID;
import com.tencent.qcloud.tuicore.interfaces.TUIInitializer;

@AutoService(TUIInitializer.class)
@TUIInitializerID("TIMCommon")
public class TIMCommonService implements TUIInitializer {

    @Override
    public void init(Context context) {
        TUIThemeManager.addLightTheme(R.style.TIMCommonLightTheme);
        TUIThemeManager.addLivelyTheme(R.style.TIMCommonLivelyTheme);
        TUIThemeManager.addSeriousTheme(R.style.TIMCommonSeriousTheme);
    }

    public static Context getAppContext() {
        return ServiceInitializer.getAppContext();
    }
}
