package com.tencent.qcloud.tuikit.tuichat.bean.message.reply;

import com.tencent.qcloud.tuikit.tuichat.bean.message.FaceMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;

public class FaceReplyQuoteBean extends TUIReplyQuoteBean {
    private byte[] data;
    private int index;
    @Override
    public void onProcessReplyQuoteBean(TUIMessageBean messageBean) {
        if (messageBean instanceof FaceMessageBean) {
            data = ((FaceMessageBean) messageBean).getData();
            index = ((FaceMessageBean) messageBean).getIndex();
        }
    }

    public byte[] getData() {
        if (data != null) {
            return data;
        } else {
            return new byte[0];
        }
    }

    public int getIndex() {
        return index;
    }

}
