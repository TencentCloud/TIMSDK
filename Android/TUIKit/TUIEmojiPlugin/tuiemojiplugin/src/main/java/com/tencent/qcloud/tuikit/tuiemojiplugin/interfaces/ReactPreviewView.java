package com.tencent.qcloud.tuikit.tuiemojiplugin.interfaces;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.MessageReactionBean;

public interface ReactPreviewView {
    void setData(MessageReactionBean messageReactionBean);
    TUIMessageBean getMessageBean();
    void setMessageBean(TUIMessageBean messageBean);
}
