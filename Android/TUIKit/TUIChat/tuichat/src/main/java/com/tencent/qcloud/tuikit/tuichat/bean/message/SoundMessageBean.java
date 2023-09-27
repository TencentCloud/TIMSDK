package com.tencent.qcloud.tuikit.tuichat.bean.message;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMSoundElem;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.SoundReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatFileDownloadPresenter;

import java.io.File;

public class SoundMessageBean extends TUIMessageBean {
    private static final int SOUND_HAS_NOT_PLAYED = 0;
    private static final int SOUND_PLAYED = 1;

    private V2TIMSoundElem soundElem;

    private boolean isPlaying = false;

    @Override
    public String onGetDisplayString() {
        return getExtra();
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        soundElem = v2TIMMessage.getSoundElem();
        File soundFile = ChatFileDownloadPresenter.getSoundMessageFile(this);
        if (soundFile == null) {
            ChatFileDownloadPresenter.downloadSound(this, null);
        }
        setExtra(TUIChatService.getAppContext().getString(R.string.audio_extra));
    }

    public void setPlayed() {
        if (getV2TIMMessage() != null) {
            getV2TIMMessage().setLocalCustomInt(SOUND_PLAYED);
        }
    }

    public boolean hasPlayed() {
        if (getV2TIMMessage() != null) {
            int customInt = getV2TIMMessage().getLocalCustomInt();
            return customInt == SOUND_PLAYED;
        }
        return false;
    }

    public String getUUID() {
        if (soundElem != null) {
            return soundElem.getUUID();
        }
        return "";
    }

    public int getDuration() {
        if (soundElem != null) {
            return soundElem.getDuration();
        }
        return 0;
    }

    public void setPlaying(boolean playing) {
        isPlaying = playing;
    }

    public boolean isPlaying() {
        return isPlaying;
    }

    @Override
    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return SoundReplyQuoteBean.class;
    }
}
