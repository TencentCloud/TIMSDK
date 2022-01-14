package com.tencent.qcloud.tim.demo.thirdpush.OEMPush;

import android.content.Context;
import android.net.Uri;
import android.os.Bundle;

import com.huawei.hms.push.HmsMessageService;
import com.huawei.hms.push.RemoteMessage;
import com.tencent.qcloud.tim.demo.thirdpush.ThirdPushTokenMgr;
import com.tencent.qcloud.tim.demo.utils.BrandUtil;
import com.tencent.qcloud.tim.demo.utils.DemoLog;

public class HUAWEIHmsMessageService extends HmsMessageService {

    private static final String TAG = HUAWEIHmsMessageService.class.getSimpleName();

    @Override
    public void onMessageReceived(RemoteMessage message) {
        DemoLog.i(TAG, "onMessageReceived message=" + message);
    }

    @Override
    public void onMessageSent(String msgId) {
        DemoLog.i(TAG, "onMessageSent msgId=" + msgId);
    }

    @Override
    public void onSendError(String msgId, Exception exception) {
        DemoLog.i(TAG, "onSendError msgId=" + msgId);
    }

    @Override
    public void onNewToken(String token) {
        DemoLog.i(TAG, "onNewToken token=" + token);
        ThirdPushTokenMgr.getInstance().setThirdPushToken(token);
        ThirdPushTokenMgr.getInstance().setPushTokenToTIM();
    }

    @Override
    public void onTokenError(Exception exception) {
        DemoLog.i(TAG, "onTokenError exception=" + exception);
    }

    @Override
    public void onMessageDelivered(String msgId, Exception exception) {
        DemoLog.i(TAG, "onMessageDelivered msgId=" + msgId);
    }


    public static void updateBadge(final Context context, final int number) {
        if (!BrandUtil.isBrandHuawei()) {
            return;
        }
        DemoLog.i(TAG, "huawei badge = " + number);
        try {
            Bundle extra = new Bundle();
            extra.putString("package", "com.tencent.qcloud.tim.tuikit");
            extra.putString("class", "com.tencent.qcloud.tim.demo.SplashActivity");
            extra.putInt("badgenumber", number);
            context.getContentResolver().call(Uri.parse("content://com.huawei.android.launcher.settings/badge/"), "change_badge", null, extra);
        } catch (Exception e) {
            DemoLog.w(TAG, "huawei badge exception: " + e.getLocalizedMessage());
        }
    }
}
