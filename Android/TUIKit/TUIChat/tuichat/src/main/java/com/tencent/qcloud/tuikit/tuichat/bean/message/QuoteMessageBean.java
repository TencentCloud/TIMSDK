package com.tencent.qcloud.tuikit.tuichat.bean.message;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.tuichat.bean.ReplyPreviewBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.ReplyReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TextReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;

/**
 * Quote Message
 */
public class QuoteMessageBean extends TUIMessageBean {

    // quote content
    private TUIMessageBean contentMessageBean;

    // origin message
    private TUIMessageBean originMessageBean;

    private final String originMsgId;
    private final String originMsgAbstract;
    private final String originMsgSender;
    private final int originMsgType;
    private final int version;

    private TUIReplyQuoteBean replyQuoteBean;

    public QuoteMessageBean(ReplyPreviewBean replyPreviewBean) {
        originMsgId = replyPreviewBean.getMessageID();
        originMsgAbstract = replyPreviewBean.getMessageAbstract();
        originMsgSender = replyPreviewBean.getMessageSender();
        originMsgType = replyPreviewBean.getMessageType();
        version = replyPreviewBean.getVersion();
        originMessageBean = replyPreviewBean.getOriginalMessageBean();
    }

    @Override
    public String onGetDisplayString() {
        if (contentMessageBean != null) {
            return contentMessageBean.onGetDisplayString();
        } else {
            return "";
        }
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        contentMessageBean = ChatMessageParser.parseMessage(v2TIMMessage, true);
        generateReplyQuoteBean();
        setExtra(contentMessageBean.getExtra());
    }

    private void generateReplyQuoteBean() {
        generateDefaultReplyQuoteBean();
        if (originMessageBean == null) {
            return;
        }
        Class<? extends TUIReplyQuoteBean> quoteReplyBeanClass = originMessageBean.getReplyQuoteBeanClass();
        if (quoteReplyBeanClass != null) {
            try {
                replyQuoteBean = quoteReplyBeanClass.newInstance();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            } catch (InstantiationException e) {
                e.printStackTrace();
            }
        }
        if (replyQuoteBean != null) {
            replyQuoteBean.onProcessReplyQuoteBean(originMessageBean);
            replyQuoteBean.setMessageBean(originMessageBean);
            replyQuoteBean.setMessageType(originMsgType);
            replyQuoteBean.setDefaultAbstract(originMsgAbstract);
        }
    }

    private void generateDefaultReplyQuoteBean() {
        replyQuoteBean = new TextReplyQuoteBean();
        replyQuoteBean.setDefaultAbstract(originMsgAbstract);
        replyQuoteBean.setMessageType(originMsgType);
    }

    public TUIMessageBean getContentMessageBean() {
        return contentMessageBean;
    }

    public void setOriginMessageBean(TUIMessageBean originMessageBean) {
        this.originMessageBean = originMessageBean;
        generateReplyQuoteBean();
    }

    public void setReplyQuoteBean(TUIReplyQuoteBean replyQuoteBean) {
        this.replyQuoteBean = replyQuoteBean;
    }

    public TUIMessageBean getOriginMessageBean() {
        return originMessageBean;
    }

    public String getOriginMsgId() {
        return originMsgId;
    }

    public String getOriginMsgAbstract() {
        return originMsgAbstract;
    }

    public String getOriginMsgSender() {
        return originMsgSender;
    }

    public int getOriginMsgType() {
        return originMsgType;
    }

    public int getVersion() {
        return version;
    }

    public TUIReplyQuoteBean getReplyQuoteBean() {
        return replyQuoteBean;
    }

    @Override
    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return ReplyReplyQuoteBean.class;
    }
}
