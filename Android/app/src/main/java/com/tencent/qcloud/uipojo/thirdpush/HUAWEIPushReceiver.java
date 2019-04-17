package com.tencent.qcloud.uipojo.thirdpush;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import com.huawei.hms.support.api.push.PushReceiver;

/**
 * Created by vinsonswang on 2019/2/27.
 */

public class HUAWEIPushReceiver extends PushReceiver {
    private static final String TAG = "HUAWEIPushReceiver";
    @Override
    public boolean onPushMsg(Context context, byte[] msgBytes, Bundle extras) {
        try {
            //CP可以自己解析消息内容，然后做相应的处理
            String content = new String(msgBytes, "UTF-8");
            Log.i(TAG, "收到PUSH透传消息,消息内容为:" + content);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public void onToken(Context context, String token, Bundle extras) {
        Log.i(TAG, "onToken:" + token);
        ThirdPushTokenMgr.getInstance().setThirdPushToken(token);
        ThirdPushTokenMgr.getInstance().setPushTokenToTIM();
    }
}
