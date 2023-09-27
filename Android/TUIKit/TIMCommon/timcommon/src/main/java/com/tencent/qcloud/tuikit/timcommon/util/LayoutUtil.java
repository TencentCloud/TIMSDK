package com.tencent.qcloud.tuikit.timcommon.util;

import android.content.Context;
import android.content.res.Configuration;
import android.view.View;

import com.tencent.qcloud.tuicore.ServiceInitializer;

public class LayoutUtil {

    public static boolean isRTL() {
        Context context = ServiceInitializer.getAppContext();
        Configuration configuration = context.getResources().getConfiguration();
        int layoutDirection = configuration.getLayoutDirection();
        return layoutDirection == View.LAYOUT_DIRECTION_RTL;
    }
}
