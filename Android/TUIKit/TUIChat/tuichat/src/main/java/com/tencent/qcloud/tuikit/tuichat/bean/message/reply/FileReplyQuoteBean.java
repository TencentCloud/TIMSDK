package com.tencent.qcloud.tuikit.tuichat.bean.message.reply;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;

public class FileReplyQuoteBean extends TUIReplyQuoteBean {
    private String fileName;

    @Override
    public void onProcessReplyQuoteBean(TUIMessageBean messageBean) {
        if (messageBean instanceof FileMessageBean) {
            fileName = ((FileMessageBean) messageBean).getFileName();
        }
    }

    public String getFileName() {
        return fileName;
    }
}
