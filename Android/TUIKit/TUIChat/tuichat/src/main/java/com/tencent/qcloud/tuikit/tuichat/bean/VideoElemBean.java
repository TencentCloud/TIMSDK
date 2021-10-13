package com.tencent.qcloud.tuikit.tuichat.bean;

import com.tencent.imsdk.v2.V2TIMDownloadCallback;
import com.tencent.imsdk.v2.V2TIMElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMVideoElem;

public class VideoElemBean {
    private V2TIMVideoElem videoElem;

    public void setVideoElem(V2TIMVideoElem videoElem) {
        this.videoElem = videoElem;
    }

    public String getSnapshotUUID() {
        if (videoElem != null) {
            return videoElem.getSnapshotUUID();
        }
        return "";
    }

    public String getVideoUUID() {
        if (videoElem != null) {
            return videoElem.getVideoUUID();
        }
        return "";
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

    public void downloadSnapshot(String path, VideoDownloadCallback callback) {
        if (videoElem != null) {
            videoElem.downloadSnapshot(path, new V2TIMDownloadCallback() {
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

    public void downloadVideo(String path, VideoDownloadCallback callback) {
        if (videoElem != null) {
            videoElem.downloadVideo(path, new V2TIMDownloadCallback() {
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

    public interface VideoDownloadCallback {
        void onProgress(long currentSize, long totalSize);

        void onSuccess();

        void onError(int code, String desc);
    }

    public static VideoElemBean createVideoElemBean(MessageInfo messageInfo) {
        VideoElemBean videoElemBean = null;
        if (messageInfo != null) {
            V2TIMMessage message = messageInfo.getTimMessage();
            if (message != null) {
                if (message.getElemType() == V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO) {
                    videoElemBean = new VideoElemBean();
                    V2TIMVideoElem videoElem = message.getVideoElem();
                    videoElemBean.setVideoElem(videoElem);
                }
            }
        }
        return videoElemBean;
    }
}
