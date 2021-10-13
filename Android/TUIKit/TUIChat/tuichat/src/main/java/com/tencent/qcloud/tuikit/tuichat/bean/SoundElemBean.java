package com.tencent.qcloud.tuikit.tuichat.bean;

import com.tencent.imsdk.v2.V2TIMDownloadCallback;
import com.tencent.imsdk.v2.V2TIMElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMSoundElem;

public class SoundElemBean {
    private V2TIMSoundElem soundElem;

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

    public interface SoundDownloadCallback {
        void onProgress(long currentSize, long totalSize);

        void onSuccess();

        void onError(int code, String desc);
    }

    public static SoundElemBean createSoundElemBean(MessageInfo messageInfo) {
        SoundElemBean soundElemBean = null;
        if (messageInfo != null) {
            V2TIMMessage message = messageInfo.getTimMessage();
            if (message != null) {
                if (message.getElemType() == V2TIMMessage.V2TIM_ELEM_TYPE_SOUND) {
                    soundElemBean = new SoundElemBean();
                    V2TIMSoundElem soundElem = message.getSoundElem();
                    soundElemBean.setSoundElem(soundElem);
                }
            }
        }
        return soundElemBean;
    }
}
