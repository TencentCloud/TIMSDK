package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;

public class EvaluationMessageReplyQuoteBean extends TUIReplyQuoteBean<EvaluationMessageBean> {
    private String text;

    public String getText() {
        return text;
    }

    @Override
    public void onProcessReplyQuoteBean(EvaluationMessageBean messageBean) {
        text = messageBean.getExtra();
    }
}
