package com.tencent.qcloud.tuikit.timcommon.util;

import android.app.Application;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.text.TextUtils;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.timcommon.R;
import java.lang.reflect.Method;

public class TUIUtil {
    private static String currentProcessName = "";

    public static String getProcessName() {
        if (!TextUtils.isEmpty(currentProcessName)) {
            return currentProcessName;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            currentProcessName = Application.getProcessName();
            return currentProcessName;
        }

        try {
            final Method declaredMethod = Class.forName("android.app.ActivityThread", false, Application.class.getClassLoader())
                                              .getDeclaredMethod("currentProcessName", (Class<?>[]) new Class[0]);
            declaredMethod.setAccessible(true);
            final Object invoke = declaredMethod.invoke(null, new Object[0]);
            if (invoke instanceof String) {
                currentProcessName = (String) invoke;
            }
        } catch (Throwable e) {
            e.printStackTrace();
        }

        return currentProcessName;
    }

    public static int getDefaultGroupIconResIDByGroupType(Context context, String groupType) {
        if (context == null || TextUtils.isEmpty(groupType)) {
            return R.drawable.core_default_group_icon_community;
        }
        if (TextUtils.equals(groupType, V2TIMManager.GROUP_TYPE_WORK)) {
            return TUIThemeManager.getAttrResId(context, R.attr.core_default_group_icon_work);
        } else if (TextUtils.equals(groupType, V2TIMManager.GROUP_TYPE_MEETING)) {
            return TUIThemeManager.getAttrResId(context, R.attr.core_default_group_icon_meeting);
        } else if (TextUtils.equals(groupType, V2TIMManager.GROUP_TYPE_PUBLIC)) {
            return TUIThemeManager.getAttrResId(context, R.attr.core_default_group_icon_public);
        } else if (TextUtils.equals(groupType, V2TIMManager.GROUP_TYPE_COMMUNITY)) {
            return TUIThemeManager.getAttrResId(context, R.attr.core_default_group_icon_community);
        }
        return R.drawable.core_default_group_icon_community;
    }

    public static Drawable newDrawable(Drawable drawable) {
        if (drawable == null) {
            return null;
        }
        Drawable.ConstantState state = drawable.getConstantState();
        if (state != null) {
            return state.newDrawable().mutate();
        }
        return drawable.mutate();
    }
}
