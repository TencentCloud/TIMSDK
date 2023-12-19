package com.tencent.qcloud.tuikit.tuichatbotplugin.model;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuikit.tuichatbotplugin.util.TUIChatBotLog;
import com.tencent.qcloud.tuikit.tuichatbotplugin.TUIChatBotConstants;

import java.util.ArrayList;
import java.util.List;

public class TUIChatBotProvider {
    private static final String TAG = "TUIChatBotProvider";
    public TUIChatBotProvider() {}

    public void getChatBotUserInfo(V2TIMValueCallback<List<V2TIMUserFullInfo>> callback) {
        List<String> userList = new ArrayList<>();
        userList.add(TUIChatBotConstants.CHAT_BOT_ID);
        V2TIMManager.getInstance().getUsersInfo(userList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                if (callback != null) {
                    callback.onSuccess(v2TIMUserFullInfos);
                }
            }

            @Override
            public void onError(int code, String desc) {
                TUIChatBotLog.e(TAG, "getChatBotUserInfo error:" + code + ", desc:" + desc);
            }
        });
    }
}
