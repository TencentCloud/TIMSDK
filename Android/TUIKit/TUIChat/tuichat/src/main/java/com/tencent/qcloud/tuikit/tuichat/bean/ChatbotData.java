package com.tencent.qcloud.tuikit.tuichat.bean;

import com.google.gson.Gson;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class ChatbotData implements Serializable {
    private static final String TAG = "ChatbotData";
    public static final int FINISHED = 1;
    public static final int SRC_FLOW_MESSAGE = 2;
    public static final int SRC_ERROR = 23;
    public static final int SRC_INTERRUPT = 22;

    public int chatbotPlugin;
    public int src;
    public String errorInfo = "";
    public List<String> chunks = new ArrayList<>();
    public int isFinished = 1;
    public String msgKey = "";
    public transient boolean isFlowMessage = true;

    public static ChatbotData parseJson(String jsonStr) {
        ChatbotData data = null;
        Gson gson = new Gson();
        try {
            data = gson.fromJson(jsonStr, ChatbotData.class);
            data.isFlowMessage = data.src == SRC_FLOW_MESSAGE;
        } catch (Exception e) {
            TUIChatLog.e(TAG, "parseJson error" + e.getMessage());
        }
        return data;
    }
}