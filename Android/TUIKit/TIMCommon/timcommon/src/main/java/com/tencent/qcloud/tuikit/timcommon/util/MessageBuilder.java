package com.tencent.qcloud.tuikit.timcommon.util;

import android.text.TextUtils;
import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import java.util.HashMap;

public class MessageBuilder {
    private static final String TAG = MessageBuilder.class.getSimpleName();

    public static void mergeCloudCustomData(TUIMessageBean messageBean, String key, Object data) {
        if (messageBean == null || messageBean.getV2TIMMessage() == null) {
            return;
        }
        String cloudCustomData = messageBean.getV2TIMMessage().getCloudCustomData();
        Gson gson = new Gson();
        HashMap hashMap = null;
        if (TextUtils.isEmpty(cloudCustomData)) {
            hashMap = new HashMap();
        } else {
            try {
                hashMap = gson.fromJson(cloudCustomData, HashMap.class);
            } catch (JsonSyntaxException e) {
                TIMCommonLog.e(TAG, " mergeCloudCustomData error " + e.getMessage());
            }
        }
        if (hashMap != null) {
            hashMap.put(key, data);
            cloudCustomData = gson.toJson(hashMap);
        }
        messageBean.getV2TIMMessage().setCloudCustomData(cloudCustomData);
    }
}
