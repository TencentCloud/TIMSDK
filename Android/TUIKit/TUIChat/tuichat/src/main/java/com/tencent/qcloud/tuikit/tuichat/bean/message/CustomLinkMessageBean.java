package com.tencent.qcloud.tuikit.tuichat.bean.message;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;

import java.util.HashMap;

public class CustomLinkMessageBean extends TUIMessageBean {

    private String text;
    private String link;

    @Override
    public String onGetDisplayString() {
        return text;
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        // 自定义消息view的实现，这里仅仅展示文本信息，并且实现超链接跳转
        text = TUIChatService.getAppContext().getString(R.string.no_support_msg);
        link = "";
        String data = new String(v2TIMMessage.getCustomElem().getData());
        try {
            HashMap map = new Gson().fromJson(data, HashMap.class);
            if (map != null) {
                text = (String) map.get("text");
                link = (String) map.get("link");
            }
        } catch (JsonSyntaxException e) {

        }
        setExtra(text);
    }

    public String getText() {
        return text;
    }

    public String getLink() {
        return link;
    }
}
