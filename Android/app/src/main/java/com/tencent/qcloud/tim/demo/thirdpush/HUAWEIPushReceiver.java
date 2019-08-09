package com.tencent.qcloud.tim.demo.thirdpush;

import android.content.Context;
import android.os.Bundle;

import com.huawei.hms.support.api.push.PushReceiver;
import com.tencent.qcloud.tim.demo.utils.DemoLog;

import java.nio.charset.StandardCharsets;

public class HUAWEIPushReceiver extends PushReceiver {

    private static final String TAG = HUAWEIPushReceiver.class.getSimpleName();

    @Override
    public boolean onPushMsg(Context context, byte[] msgBytes, Bundle extras) {
        try {
            //CP可以自己解析消息内容，然后做相应的处理
            String content = null;
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
                content = new String(msgBytes, StandardCharsets.UTF_8);
            }
            DemoLog.i(TAG, "收到PUSH透传消息,消息内容为 : " + content);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public void onToken(Context context, String token, Bundle extras) {
        DemoLog.i(TAG, "onToken = " + token);
        ThirdPushTokenMgr.getInstance().setThirdPushToken(token);
        ThirdPushTokenMgr.getInstance().setPushTokenToTIM();
    }
}
