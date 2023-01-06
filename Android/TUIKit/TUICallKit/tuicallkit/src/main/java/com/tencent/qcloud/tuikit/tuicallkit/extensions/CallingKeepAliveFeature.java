package com.tencent.qcloud.tuikit.tuicallkit.extensions;

import android.content.Context;

import com.tencent.qcloud.tuikit.tuicallkit.service.TUICallService;
import com.tencent.qcloud.tuikit.tuicallkit.utils.DeviceUtils;

public class CallingKeepAliveFeature {
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
