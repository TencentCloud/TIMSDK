package com.huawei.android.hms.agent.common;

import android.app.Activity;

/**
 * Activity onPause 事件回调接口
 */
public interface IActivityPauseCallback {

    /**
     * Activity onPause回调
     * @param activity 发生 onPause 事件的activity
     */
    void onActivityPause(Activity activity);
}
