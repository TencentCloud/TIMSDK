package com.tencent.qcloud.tuikit.tuichat.bean.message;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.CustomHelloMessage;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.CustomLinkReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TUIReplyQuoteBean;

import java.util.HashMap;

/**
 * 自定义超链接消息
 */
public class CustomLinkMessageBean extends TUIMessageBean {

    private CustomHelloMessage customHelloMessage;

    @Override
    public String onGetDisplayString() {
        return getText();
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        String data = new String(v2TIMMessage.getCustomElem().getData());
        customHelloMessage = new Gson().fromJson(data, CustomHelloMessage.class);
        if (customHelloMessage != null) {
            setExtra(customHelloMessage.text);
        } else {
            String text = TUIChatService.getAppContext().getString(R.string.no_support_msg);
            setExtra(text);
        }
    }

    public String getText() {
        if (customHelloMessage != null) {
            return customHelloMessage.text;
        }
        return getExtra();
    }

    public String getLink() {
        if (customHelloMessage != null) {
            return customHelloMessage.link;
        }
        return "";
    }

    @Override
    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return CustomLinkReplyQuoteBean.class;
    }
}
