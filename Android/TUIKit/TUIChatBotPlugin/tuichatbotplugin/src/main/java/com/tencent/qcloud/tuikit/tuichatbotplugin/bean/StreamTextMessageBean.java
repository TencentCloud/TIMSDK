package com.tencent.qcloud.tuikit.tuichatbotplugin.bean;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichatbotplugin.util.TUIChatBotMessageParser;

import java.util.HashMap;
import java.util.Map;

public class StreamTextMessageBean extends TextMessageBean {
    private int displayedContentLength = 0;
    private String content;

    @Override
    public String onGetDisplayString() {
        return getExtra();
    }

    @Override
    public boolean customReloadWithNewMsg(V2TIMMessage v2TIMMessage) {
        String newContent = TUIChatBotMessageParser.getStreamText(v2TIMMessage);
        if (newContent.length() <= displayedContentLength) {
            return true;
        }

        setV2TIMMessage(v2TIMMessage);

        Map<String, Object> param = new HashMap<>();
        param.put(TUIChatConstants.MESSAGE_BEAN, this);
        param.put(TUIChatConstants.DATA_CHANGE_TYPE, IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE);
        TUICore.notifyEvent(TUIConstants.TUIChat.EVENT_KEY_MESSAGE_EVENT, TUIConstants.TUIChat.EVENT_SUB_KEY_MESSAGE_INFO_CHANGED, param);

        return true;
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        content = TUIChatBotMessageParser.getStreamText(v2TIMMessage);
        if (getMessageSource() != TUIMessageBean.MSG_SOURCE_ONLINE_PUSH) {
            setExtra(content);
        }
    }

    public void setDisplayedContentLength(int displayedContentLength) {
        this.displayedContentLength = displayedContentLength;
    }

    public int getDisplayedContentLength() {
        return displayedContentLength;
    }

    public String getContent() {
        return content;
    }

}
