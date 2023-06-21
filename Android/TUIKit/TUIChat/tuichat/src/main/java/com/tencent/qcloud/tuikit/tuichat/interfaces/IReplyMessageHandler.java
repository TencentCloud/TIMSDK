package com.tencent.qcloud.tuikit.tuichat.interfaces;

import com.tencent.qcloud.tuikit.timcommon.bean.MessageRepliesBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;

import java.util.Map;

public interface IReplyMessageHandler {
    void updateData(TUIMessageBean messageBean);

    void onRepliesMessageFound(Map<MessageRepliesBean.ReplyBean, TUIMessageBean> messageBeanMap);
}
