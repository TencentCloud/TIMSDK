package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;

public class CardMessageReplyQuoteBean extends TUIReplyQuoteBean<CardMessageBean> {
    private String text;

    public String getText() {
        return text;
    }

    @Override
    public void onProcessReplyQuoteBean(CardMessageBean messageBean) {
        text = messageBean.getExtra();
    }
}
