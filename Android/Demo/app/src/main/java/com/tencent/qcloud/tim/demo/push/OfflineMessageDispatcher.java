package com.tencent.qcloud.tim.demo.push;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.text.TextUtils;

import com.google.gson.Gson;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.TIMAppService;
import com.tencent.qcloud.tim.demo.utils.BrandUtil;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tuicore.push.OfflinePushExtBusinessInfo;
import com.tencent.qcloud.tuicore.push.OfflinePushExtInfo;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import java.util.Map;
import java.util.Set;

public class OfflineMessageDispatcher {
    private static final String TAG = OfflineMessageDispatcher.class.getSimpleName();
    private static final String OEMMessageKey = "ext";
    private static final String XIAOMIMessageKey = "key_message";

    public static OfflinePushExtInfo parseOfflineMessage(Intent intent) {
        DemoLog.i(TAG, "intent: " + intent);
        if (intent == null) {
            return null;
        }

        DemoLog.i(TAG, "parse OEM push");
        Bundle bundle = intent.getExtras();
        DemoLog.i(TAG, "bundle: " + bundle);
        if (bundle == null) {
            DemoLog.i(TAG, "bundle is null");
            return null;
        } else {
            String ext = bundle.getString(OEMMessageKey);
            DemoLog.i(TAG, "push custom data ext: " + ext);
            if (TextUtils.isEmpty(ext)) {
                if (BrandUtil.isBrandXiaoMi()) {
                    ext = getXiaomiMessage(bundle);
                    return getOfflinePushExtInfo(ext);
                } else if (BrandUtil.isBrandOppo()) {
                    ext = getOPPOMessage(bundle);
                    return getOPPOOfflinePushExtInfo(ext);
                }
                DemoLog.i(TAG, "ext is null");
                return null;
            } else {
                return getOfflinePushExtInfo(ext);
            }
        }
    }

    private static String getXiaomiMessage(Bundle bundle) {
        Map extra = null;
        try {
            Object objectMessage = bundle.getSerializable(XIAOMIMessageKey);
            extra = (Map) objectMessage.getClass().getMethod("getExtra").invoke(objectMessage);
        } catch (Exception e) {
            DemoLog.e(TAG, "getXiaomiMessage e = " + e);
        }

        if (extra == null) {
            DemoLog.e(TAG, "getXiaomiMessage is null");
            return "";
        }

        DemoLog.i(TAG, "getXiaomiMessage ext: " + extra.get("ext").toString());
        return extra.get("ext").toString();
    }

    private static String getOPPOMessage(Bundle bundle) {
        Set<String> set = bundle.keySet();
        if (set != null) {
            for (String key : set) {
                Object value = bundle.get(key);
                DemoLog.i(TAG, "push custom data key: " + key + " value: " + value);
                if (TextUtils.equals("entity", key)) {
                    return value.toString();
                }
            }
        }
        return null;
    }

    public static OfflinePushExtInfo getOfflinePushExtInfo(String ext) {
        if (TextUtils.isEmpty(ext)) {
            return null;
        }
        OfflinePushExtInfo offlinePushExtInfo = null;
        try {
            offlinePushExtInfo = new Gson().fromJson(ext, OfflinePushExtInfo.class);
        } catch (Exception e) {
            DemoLog.w(TAG, "getOfflinePushExtInfo: " + e.getMessage());
        }
        if (offlinePushExtInfo == null) {
            return null;
        }

        // getCustomData example
        /*byte[] byteData = offlinePushExtInfo.getEntity().getCustomData();
        String customString = "";
        if (byteData != null && byteData.length > 0) {
            try {
                customString = new String(byteData, "UTF-8");
            } catch (UnsupportedEncodingException e) {
                DemoLog.w(TAG, "getCustomData e: " + e);
            }
        }
        DemoLog.e(TAG, "customString = " + customString);
        ChatInfo chatInfo = null;
        try{
            chatInfo = new Gson().fromJson(customString, ChatInfo.class);
        } catch (Exception e) {
            DemoLog.w(TAG, "getCustomData fromJson e: " + e);
        }*/

        return OfflinePushExtInfoValidCheck(offlinePushExtInfo);
    }

    private static OfflinePushExtInfo getOPPOOfflinePushExtInfo(String ext) {
        if (TextUtils.isEmpty(ext)) {
            return null;
        }

        OfflinePushExtInfo offlinePushExtInfo = new OfflinePushExtInfo();
        OfflinePushExtBusinessInfo bean = null;
        try {
            bean = new Gson().fromJson(ext, OfflinePushExtBusinessInfo.class);
        } catch (Exception e) {
            DemoLog.w(TAG, "getOPPOOfflinePushExtInfo: " + e.getMessage());
        }

        if (bean == null) {
            return null;
        }

        offlinePushExtInfo.setBusinessInfo(bean);
        return OfflinePushExtInfoValidCheck(offlinePushExtInfo);
    }

    private static OfflinePushExtInfo OfflinePushExtInfoValidCheck(OfflinePushExtInfo offlinePushExtInfo) {
        if (offlinePushExtInfo == null || offlinePushExtInfo.getBusinessInfo() == null) {
            return null;
        }

        int version = offlinePushExtInfo.getBusinessInfo().getVersion();
        int action = offlinePushExtInfo.getBusinessInfo().getChatAction();
        if (version != 1 || (action != OfflinePushExtInfo.REDIRECT_ACTION_CHAT && action != OfflinePushExtInfo.REDIRECT_ACTION_CALL)) {
            PackageManager packageManager = TIMAppService.getAppContext().getPackageManager();
            String label = String.valueOf(packageManager.getApplicationLabel(TIMAppService.getAppContext().getApplicationInfo()));
            ToastUtil.toastLongMessage(
                    TIMAppService.getAppContext().getString(R.string.you_app) + label + TIMAppService.getAppContext().getString(R.string.low_version));
            DemoLog.e(TAG, "unknown version: " + version + " or action: " + action);
            return null;
        }

        return offlinePushExtInfo;
    }
}
