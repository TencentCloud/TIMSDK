package com.tencent.qcloud.tuikit.timcommon.util;

import android.text.TextUtils;
import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageFeature;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageRepliesBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import java.util.HashMap;
import java.util.Map;

public class MessageParser {
    private static final String TAG = MessageParser.class.getSimpleName();

    public static MessageRepliesBean parseMessageReplies(TUIMessageBean messageBean) {
        V2TIMMessage message = messageBean.getV2TIMMessage();
        String cloudCustomData = message.getCloudCustomData();

        try {
            Gson gson = new Gson();
            HashMap hashMap = gson.fromJson(cloudCustomData, HashMap.class);
            if (hashMap != null) {
                Object repliesContentObj = hashMap.get(TIMCommonConstants.MESSAGE_REPLIES_KEY);
                MessageRepliesBean repliesBean = null;
                if (repliesContentObj instanceof Map) {
                    repliesBean = gson.fromJson(gson.toJson(repliesContentObj), MessageRepliesBean.class);
                }
                if (repliesBean != null) {
                    if (repliesBean.getVersion() > MessageRepliesBean.VERSION) {
                        return null;
                    }
                    return repliesBean;
                }
            }
        } catch (JsonSyntaxException e) {
            TIMCommonLog.e(TAG, " getCustomJsonMap error ");
        }
        return null;
    }

    public static MessageFeature isSupportTyping(TUIMessageBean messageBean) {
        String cloudCustomData = messageBean.getV2TIMMessage().getCloudCustomData();
        if (TextUtils.isEmpty(cloudCustomData)) {
            return null;
        }
        try {
            Gson gson = new Gson();
            HashMap featureHashMap = gson.fromJson(cloudCustomData, HashMap.class);
            if (featureHashMap != null) {
                Object featureContentObj = featureHashMap.get(TIMCommonConstants.MESSAGE_FEATURE_KEY);
                MessageFeature messageFeature = null;
                if (featureContentObj instanceof Map) {
                    messageFeature = gson.fromJson(gson.toJson(featureContentObj), MessageFeature.class);
                }
                if (messageFeature != null) {
                    if (messageFeature.getVersion() > MessageFeature.VERSION) {
                        return null;
                    }

                    return messageFeature;
                }
            }
        } catch (JsonSyntaxException e) {
            TIMCommonLog.e(TAG, " isSupportTyping exception e = " + e);
        }
        return null;
    }
}
