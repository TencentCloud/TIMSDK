package com.tencent.qcloud.tuikit.tuichat.bean.message;

import android.text.TextUtils;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.tuichat.bean.ReplyPreviewBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.ReplyReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TextReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;

import java.util.Set;

/**
 * Quote Message
 */
public class QuoteMessageBean extends TUIMessageBean {
    // quote content
    private TUIMessageBean contentMessageBean;

    // origin message
    private TUIMessageBean originMessageBean;

    private final String originMsgId;
    private String originMsgAbstract;
    private String originMsgSender;
    private int originMsgType;
    private final long originMsgTime;
    private final long originMsgSequence;
    private final int version;

    private boolean abstractEnable = false;

    private TUIReplyQuoteBean replyQuoteBean;

    public QuoteMessageBean(ReplyPreviewBean replyPreviewBean) {
        originMsgId = replyPreviewBean.getMessageID();
        originMsgAbstract = replyPreviewBean.getMessageAbstract();
        originMsgSender = replyPreviewBean.getMessageSender();
        originMsgType = replyPreviewBean.getMessageType();
        originMsgTime = replyPreviewBean.getMessageTime();
        originMsgSequence = replyPreviewBean.getMessageSequence();
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
        contentMessageBean = ChatMessageParser.parseMessageIgnoreReply(v2TIMMessage);
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
        if (originMessageBean != null) {
            if (TextUtils.isEmpty(originMsgSender)) {
                originMsgSender = originMessageBean.getSender();
            }
            if (TextUtils.isEmpty(originMsgAbstract)) {
                originMsgAbstract = ChatMessageParser.getReplyMessageAbstract(originMessageBean);
            }
            originMsgType = originMessageBean.getMsgType();
        }
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
        if (TextUtils.isEmpty(originMsgAbstract)) {
            return "";
        }
        return originMsgAbstract;
    }

    public String getOriginMsgSender() {
        if (TextUtils.isEmpty(originMsgSender)) {
            return "";
        }
        UserBean userBean = getUserBean(originMsgSender);
        if (userBean != null) {
             return userBean.getDisplayName();
        }
        return originMsgSender;
    }

    public int getOriginMsgType() {
        return originMsgType;
    }

    public long getOriginMsgTime() {
        return originMsgTime;
    }

    public long getOriginMsgSequence() {
        return originMsgSequence;
    }

    public int getVersion() {
        return version;
    }

    public TUIReplyQuoteBean getReplyQuoteBean() {
        return replyQuoteBean;
    }

    public void setAbstractEnable(boolean abstractEnable) {
        this.abstractEnable = abstractEnable;
    }

    public boolean isAbstractEnable() {
        return abstractEnable;
    }

    @Override
    public Set<String> getAdditionalUserIDList() {
        Set<String>  userIDList = super.getAdditionalUserIDList();
        if (!TextUtils.isEmpty(originMsgSender)) {
            userIDList.add(originMsgSender);
        }
        return userIDList;
    }

    @Override
    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return ReplyReplyQuoteBean.class;
    }
}
