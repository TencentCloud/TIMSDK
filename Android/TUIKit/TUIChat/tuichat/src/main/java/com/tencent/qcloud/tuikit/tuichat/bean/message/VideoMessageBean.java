package com.tencent.qcloud.tuikit.tuichat.bean.message;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMVideoElem;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.VideoReplyQuoteBean;

public class VideoMessageBean extends TUIMessageBean {
    private int imgWidth;
    private int imgHeight;
    private V2TIMVideoElem videoElem;

    @Override
    public String onGetDisplayString() {
        return getExtra();
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        V2TIMVideoElem videoEle = v2TIMMessage.getVideoElem();
        imgWidth = (int) videoEle.getSnapshotWidth();
        imgHeight = (int) videoEle.getSnapshotHeight();
        videoElem = v2TIMMessage.getVideoElem();
        setExtra(TUIChatService.getAppContext().getString(R.string.video_extra));
    }

    public void setImgHeight(int imgHeight) {
        this.imgHeight = imgHeight;
    }

    public void setImgWidth(int imgWidth) {
        this.imgWidth = imgWidth;
    }

    public int getImgHeight() {
        return imgHeight;
    }

    public int getImgWidth() {
        return imgWidth;
    }

    public int getDuration() {
        if (videoElem != null) {
            return videoElem.getDuration();
        }
        return 0;
    }

    public int getVideoSize() {
        if (videoElem != null) {
            return videoElem.getVideoSize();
        }
        return 0;
    }

    @Override
    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return VideoReplyQuoteBean.class;
    }
}
