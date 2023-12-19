package com.tencent.qcloud.tuikit.tuichatbotplugin.presenter;

import android.text.TextUtils;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;
import com.tencent.qcloud.tuikit.tuichatbotplugin.bean.BranchMessageBean;
import com.tencent.qcloud.tuikit.tuichatbotplugin.model.TUIChatBotProvider;
import com.tencent.qcloud.tuikit.tuichatbotplugin.util.TUIChatBotLog;

import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;

public class TUIChatBotPresenter {
    private static final String TAG = "TUIChatBotPresenter";
    private BranchMessageBean messageBean;
    private TUIChatBotProvider provider;

    public TUIChatBotPresenter() {
        provider = new TUIChatBotProvider();
    }

    public void setBranchMessage(BranchMessageBean currentMessage) {
        messageBean = currentMessage;
    }

    public BranchMessageBean getMessageBean() {
        return messageBean;
    }

    public void getChatBotUserInfo(V2TIMValueCallback<List<V2TIMUserFullInfo>> callback) {
        provider.getChatBotUserInfo(callback);
    }

    public void OnItemContentSelected(String content) {
        if (messageBean == null) {
            TUIChatBotLog.e(TAG, "OnItemContentSelected, messageBean is null");
            return;
        }

        String chatID = messageBean.getUserId();
        sendTextMessage(chatID, content);
    }

    public void sayHelloToChatBot(String userID) {
        JSONObject helloJson = new JSONObject();
        try {
            helloJson.put(TUIConstants.TUIChatBotPlugin.CHAT_BOT_MESSAGE_KEY, TUIConstants.TUIChatBotPlugin.CHAT_BOT_MESSAGE_VALUE);
            helloJson.put(TUIConstants.TUIChatBotPlugin.CHAT_BOT_BUSINESS_ID_SRC_KEY, TUIConstants.TUIChatBotPlugin.CHAT_BOT_BUSINESS_ID_SRC_HELLO_REQUEST);
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }

        if (!TextUtils.isEmpty(helloJson.toString())) {
            TUIMessageBean messageBean = ChatMessageBuilder.buildCustomMessage(helloJson.toString(), "", null);
            TUIChatService.getInstance().sendMessage(messageBean, userID, V2TIMConversation.V2TIM_C2C, true);
        }
    }

    public void sendTextMessage(String userID, String content) {
        TUIMessageBean messageBean = ChatMessageBuilder.buildTextMessage(content);
        TUIChatService.getInstance().sendMessage(messageBean, userID, V2TIMConversation.V2TIM_C2C, false);
    }

}
