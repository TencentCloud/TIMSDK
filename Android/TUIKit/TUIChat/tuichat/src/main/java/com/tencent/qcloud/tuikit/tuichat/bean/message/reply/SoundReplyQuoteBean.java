package com.tencent.qcloud.tuikit.tuichat.bean.message.reply;

import com.tencent.imsdk.v2.V2TIMSoundElem;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.reply.SoundReplyQuoteView;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.reply.TUIReplyQuoteView;

public class SoundReplyQuoteBean extends TUIReplyQuoteBean {
    private String dataPath;
    private V2TIMSoundElem soundElem;

    @Override
    public void onProcessReplyQuoteBean(TUIMessageBean messageBean) {
        if (messageBean instanceof SoundMessageBean) {
            dataPath = ((SoundMessageBean) messageBean).getDataPath();
            soundElem = messageBean.getV2TIMMessage().getSoundElem();
        }
    }

    public int getDuring() {
        if (soundElem != null) {
            return soundElem.getDuration();
        }
        return 0;
    }

    @Override
    public Class<? extends TUIReplyQuoteView> getReplyQuoteViewClass() {
        return SoundReplyQuoteView.class;
    }
}
