package com.tencent.qcloud.tuikit.tuichat.bean.message;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatbotData;

public class ChatbotMessageBean extends TextMessageBean {
    private static final String TAG = "ChatbotMessageBean";

    private ChatbotData chatbotData = null;

    private boolean isFinished = false;

    public boolean isFinished() {
        return isFinished;
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        if (v2TIMMessage.getCustomElem() == null || v2TIMMessage.getCustomElem().getData() == null) {
            return;
        }
        String data = new String(v2TIMMessage.getCustomElem().getData());
        chatbotData = ChatbotData.parseJson(data);
        if (chatbotData == null) {
            return;
        }
        isFinished = chatbotData.isFinished == ChatbotData.FINISHED;
        if (chatbotData.src == ChatbotData.SRC_FLOW_MESSAGE) {
            String text = String.join("", chatbotData.chunks);
            setText(text);
            setExtra(text);
        } else if (chatbotData.src == ChatbotData.SRC_ERROR) {
            setText(chatbotData.errorInfo);
            setExtra(chatbotData.errorInfo);
        }
    }
}
