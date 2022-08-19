package com.tencent.qcloud.tuikit.tuichat.bean.message;

import com.tencent.imsdk.v2.V2TIMFaceElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.FaceReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class FaceMessageBean extends TUIMessageBean {

    private V2TIMFaceElem faceElem;

    @Override
    public String onGetDisplayString() {
        return getExtra();
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        faceElem = v2TIMMessage.getFaceElem();
        if (faceElem.getIndex() < 1 || faceElem.getData() == null) {
            TUIChatLog.e("FaceMessageBean", "faceElem data is null or index<1");
            return;
        }
        setExtra(TUIChatService.getAppContext().getString(R.string.custom_emoji));
    }

    public byte[] getData() {
        if (faceElem != null) {
            return faceElem.getData();
        } else {
            return new byte[0];
        }
    }

    public int getIndex() {
        if (faceElem != null) {
            return faceElem.getIndex();
        } else {
            return 0;
        }
    }

    @Override
    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return FaceReplyQuoteBean.class;
    }
}
