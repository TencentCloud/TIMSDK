package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;

public class BotBranchMessageReplyQuoteBean extends TUIReplyQuoteBean<BotBranchMessageBean> {
    private String text;

    public String getText() {
        return text;
    }

    @Override
    public void onProcessReplyQuoteBean(BotBranchMessageBean messageBean) {
        text = messageBean.getExtra();
    }
}
