package com.tencent.qcloud.tuikit.tuichat.bean.message;

import android.text.TextUtils;
import com.tencent.imsdk.v2.V2TIMDownloadCallback;
import com.tencent.imsdk.v2.V2TIMElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMSoundElem;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.SoundReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import java.io.File;

public class SoundMessageBean extends TUIMessageBean {
    private static final int SOUND_HAS_NOT_PLAYED = 0;
    private static final int SOUND_PLAYED = 1;

    private String dataPath;
    private V2TIMSoundElem soundElem;

    private boolean isPlaying = false;

    @Override
    public String onGetDisplayString() {
        return getExtra();
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        soundElem = v2TIMMessage.getSoundElem();
        if (isSelf() && !TextUtils.isEmpty(soundElem.getPath())) {
            dataPath = soundElem.getPath();
        } else {
            final String path = TUIConfig.getRecordDownloadDir() + soundElem.getUUID();
            File file = new File(path);
            if (!file.exists()) {
                soundElem.downloadSound(path, new V2TIMDownloadCallback() {
                    @Override
                    public void onProgress(V2TIMElem.V2ProgressInfo progressInfo) {
                        long currentSize = progressInfo.getCurrentSize();
                        long totalSize = progressInfo.getTotalSize();
                        int progress = 0;
                        if (totalSize > 0) {
                            progress = (int) (100 * currentSize / totalSize);
                        }
                        if (progress > 100) {
                            progress = 100;
                        }
                        TUIChatLog.i("ChatMessageInfoUtil getSoundToFile", "progress:" + progress);
                    }

                    @Override
                    public void onError(int code, String desc) {
                        TUIChatLog.e("ChatMessageInfoUtil getSoundToFile", code + ":" + desc);
                    }

                    @Override
                    public void onSuccess() {
                        dataPath = path;
                    }
                });
            } else {
                dataPath = path;
            }
        }
        setExtra(TUIChatService.getAppContext().getString(R.string.audio_extra));
    }

    /**
     * 获取多媒体消息的保存路径
     *
     * Get the save path of multimedia messages
     *
     * @return
     */
    public String getDataPath() {
        return dataPath;
    }

    /**
     * 设置多媒体消息的保存路径
     *
     * Set the save path of multimedia messages
     *
     * @param dataPath
     */
    public void setDataPath(String dataPath) {
        this.dataPath = dataPath;
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

    public void setSoundElem(V2TIMSoundElem soundElem) {
        this.soundElem = soundElem;
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

    public void downloadSound(String path, SoundDownloadCallback callback) {
        if (soundElem != null) {
            soundElem.downloadSound(path, new V2TIMDownloadCallback() {
                @Override
                public void onProgress(V2TIMElem.V2ProgressInfo progressInfo) {
                    if (callback != null) {
                        callback.onProgress(progressInfo.getCurrentSize(), progressInfo.getTotalSize());
                    }
                }

                @Override
                public void onSuccess() {
                    if (callback != null) {
                        callback.onSuccess();
                    }
                }

                @Override
                public void onError(int code, String desc) {
                    if (callback != null) {
                        callback.onError(code, desc);
                    }
                }
            });
        }
    }

    public void setPlaying(boolean playing) {
        isPlaying = playing;
    }

    public boolean isPlaying() {
        return isPlaying;
    }

    public interface SoundDownloadCallback {
        void onProgress(long currentSize, long totalSize);

        void onSuccess();

        void onError(int code, String desc);
    }

    @Override
    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return SoundReplyQuoteBean.class;
    }
}
