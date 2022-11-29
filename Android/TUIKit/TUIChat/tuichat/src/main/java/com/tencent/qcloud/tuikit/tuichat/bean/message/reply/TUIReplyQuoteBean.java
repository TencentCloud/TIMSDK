package com.tencent.qcloud.tuikit.tuichat.bean.message.reply;

import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;

import java.io.Serializable;

public abstract class TUIReplyQuoteBean implements Serializable {
    private TUIMessageBean messageBean;
    protected String defaultAbstract;
    protected int messageType;

    public abstract void onProcessReplyQuoteBean(TUIMessageBean messageBean);

    public void setMessageBean(TUIMessageBean messageBean) {
        this.messageBean = messageBean;
    }

    public void setDefaultAbstract(String defaultAbstract) {
        this.defaultAbstract = defaultAbstract;
    }

    public void setMessageType(int messageType) {
        this.messageType = messageType;
    }

    public int getMessageType() {
        return messageType;
    }

    public TUIMessageBean getMessageBean() {
        return messageBean;
    }

    public String getDefaultAbstract() {
        return defaultAbstract;
    }

}
