package com.tencent.qcloud.tuikit.tuichatbotplugin.bean;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;

public class BranchMessageReplyQuoteBean extends TUIReplyQuoteBean<BranchMessageBean> {
    private String text;

    public String getText() {
        return text;
    }

    @Override
    public void onProcessReplyQuoteBean(BranchMessageBean messageBean) {
        text = messageBean.getExtra();
    }
}
