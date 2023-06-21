package com.tencent.qcloud.tim.tuiofflinepush.notification;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import com.tencent.qcloud.tim.tuiofflinepush.TUIOfflinePushConfig;
import com.tencent.qcloud.tim.tuiofflinepush.utils.BrandUtil;
import java.util.Map;
import java.util.Set;

public class ParseNotification {
    private static final String TAG = "TUIOfflinePush-" + ParseNotification.class.getSimpleName();
    private static final String OEMMessageKey = "ext";
    private static final String XIAOMIMessageKey = "key_message";

    public static String parseOfflineMessage(Intent intent) {
        Log.i(TAG, "intent: " + intent);
        if (intent == null) {
            return "";
        }

        Log.i(TAG, "parse OEM push");
        Bundle bundle = intent.getExtras();
        Log.i(TAG, "bundle: " + bundle);
        if (bundle == null) {
            Log.i(TAG, "bundle is null");
            return null;
        } else {
            String ext = bundle.getString(OEMMessageKey);
            Log.i(TAG, "push custom data ext: " + ext);
            if (TextUtils.isEmpty(ext)) {
                int deviceType = BrandUtil.getInstanceType();
                if (deviceType == TUIOfflinePushConfig.BRAND_XIAOMI) {
                    ext = getXiaomiMessage(bundle);
                    return getOfflineMessageBeanFromContainer(ext);
                } else if (deviceType == TUIOfflinePushConfig.BRAND_OPPO) {
                    ext = getOPPOMessage(bundle);
                    return getOfflineMessageBean(ext);
                }
                Log.i(TAG, "ext is null");
                return null;
            } else {
                return getOfflineMessageBeanFromContainer(ext);
            }
        }
    }

    private static String getXiaomiMessage(Bundle bundle) {
        Map extra = null;
        try {
            Object objectMessage = bundle.getSerializable(XIAOMIMessageKey);
            extra = (Map) objectMessage.getClass().getMethod("getExtra").invoke(objectMessage);
        } catch (Exception e) {
            Log.e(TAG, "getXiaomiMessage e = " + e);
        }

        if (extra == null) {
            Log.e(TAG, "getXiaomiMessage is null");
            return "";
        }

        Log.i(TAG, "getXiaomiMessage ext: " + extra.get("ext").toString());
        return extra.get("ext").toString();
    }

    private static String getOPPOMessage(Bundle bundle) {
        Set<String> set = bundle.keySet();
        if (set != null) {
            for (String key : set) {
                Object value = bundle.get(key);
                Log.i(TAG, "push custom data key: " + key + " value: " + value);
                if (TextUtils.equals("entity", key)) {
                    return value.toString();
                }
            }
        }
        return null;
    }

    private static String getOfflineMessageBeanFromContainer(String ext) {
        return ext;
    }

    private static String getOfflineMessageBean(String ext) {
        if (TextUtils.isEmpty(ext)) {
            return null;
        }

        return ext;
    }
}
