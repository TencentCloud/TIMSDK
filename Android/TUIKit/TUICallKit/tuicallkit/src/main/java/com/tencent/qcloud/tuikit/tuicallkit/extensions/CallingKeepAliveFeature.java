package com.tencent.qcloud.tuikit.tuicallkit.extensions;

import android.content.Context;

import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog;
import com.tencent.qcloud.tuikit.tuicallkit.service.TUICallService;
import com.tencent.qcloud.tuikit.tuicallkit.utils.DeviceUtils;

public class CallingKeepAliveFeature {
    private static final String TAG = "CallingKeepAliveFeature";

    private Context mContext;
    private boolean mEnableKeepAlive = true;

    public CallingKeepAliveFeature(Context context) {
        mContext = context;
    }

    public void enableKeepAlive(boolean enable) {
        mEnableKeepAlive = enable;
    }

    public void startKeepAlive() {
        if (!mEnableKeepAlive) {
            TUILog.i(TAG, "you have already reject keepAlive");
            return;
        }
        TUICallService.start(mContext);
    }

    public void stopKeepAlive() {
        if (DeviceUtils.isServiceRunning(mContext, TUICallService.class.getName())) {
            TUICallService.stop(mContext);
        }
    }
}
