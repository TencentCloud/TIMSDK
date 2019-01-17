package com.tencent.qcloud.uikit.common.widget;

import android.view.View;

import java.lang.reflect.Method;

/**
 * Created by valexhuang on 2018/10/11.
 */

public interface InfoCacheView {
    void saveInfo(Method method, Object value[]);

    View getRealView();
}
