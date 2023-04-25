package com.tencent.qcloud.tuikit.timcommon;

import android.content.Context;

import com.tencent.qcloud.tuicore.ServiceInitializer;

public class TIMCommonService extends ServiceInitializer {

    @Override
    public void init(Context context) {
        super.init(context);
    }

    @Override
    public int getLightThemeResId() {
        return R.style.TIMCommonLightTheme;
    }

    @Override
    public int getLivelyThemeResId() {
        return R.style.TIMCommonLivelyTheme;
    }

    @Override
    public int getSeriousThemeResId() {
        return R.style.TIMCommonSeriousTheme;
    }
}
