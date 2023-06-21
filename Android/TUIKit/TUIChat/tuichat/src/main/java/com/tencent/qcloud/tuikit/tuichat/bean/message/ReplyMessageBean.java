package com.tencent.qcloud.tuikit.tuichat.bean.message;

import com.tencent.qcloud.tuikit.tuichat.bean.ReplyPreviewBean;
/**
 * Reply Message
 */

public class ReplyMessageBean extends QuoteMessageBean {
    private final String msgRootId;

    public ReplyMessageBean(ReplyPreviewBean replyPreviewBean) {
        super(replyPreviewBean);
        msgRootId = replyPreviewBean.getMessageRootID();
    }

    public String getMsgRootId() {
        return msgRootId;
    }
}
