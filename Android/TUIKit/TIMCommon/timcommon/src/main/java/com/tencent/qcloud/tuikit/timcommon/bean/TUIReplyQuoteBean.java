package com.tencent.qcloud.tuikit.timcommon.bean;

import java.io.Serializable;

public abstract class TUIReplyQuoteBean<T extends TUIMessageBean> implements Serializable {
    private T messageBean;
    protected String defaultAbstract;
    protected int messageType;

    public abstract void onProcessReplyQuoteBean(T messageBean);

    public void setMessageBean(T messageBean) {
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

    public T getMessageBean() {
        return messageBean;
    }

    public boolean hasRiskContent() {
        if (messageBean != null) {
            return messageBean.hasRiskContent();
        }
        return false;
    }

    public String getDefaultAbstract() {
        return defaultAbstract;
    }
}
