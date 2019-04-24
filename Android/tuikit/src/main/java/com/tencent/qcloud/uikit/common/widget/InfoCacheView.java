package com.tencent.qcloud.uikit.common.widget;

import android.view.View;

import java.lang.reflect.Method;


public interface InfoCacheView {
    void saveInfo(Method method, Object value[]);

    View getRealView();
}
