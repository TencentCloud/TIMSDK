package com.tencent.qcloud.tuikit.tuichat.bean;

import com.tencent.imsdk.v2.V2TIMDownloadCallback;
import com.tencent.imsdk.v2.V2TIMElem;
import com.tencent.imsdk.v2.V2TIMImageElem;

public class ImageBean {
    private V2TIMImageElem.V2TIMImage v2TIMImage;

    public void setV2TIMImage(V2TIMImageElem.V2TIMImage v2TIMImage) {
        this.v2TIMImage = v2TIMImage;
    }

    public V2TIMImageElem.V2TIMImage getV2TIMImage() {
        return v2TIMImage;
    }

    public String getUUID() {
        if (v2TIMImage != null) {
            return v2TIMImage.getUUID();
        }
        return "";
    }

    public String getUrl() {
        if (v2TIMImage != null) {
            return v2TIMImage.getUrl();
        }
        return "";
    }

    public int getType() {
        if (v2TIMImage != null) {
            return v2TIMImage.getType();
        }
        return ImageElemBean.IMAGE_TYPE_THUMB;
    }

    public int getSize() {
        if (v2TIMImage != null) {
            return v2TIMImage.getSize();
        }
        return 0;
    }

    public int getHeight() {
        if (v2TIMImage != null) {
            return v2TIMImage.getHeight();
        }
        return 0;
    }

    public int getWidth() {
        if (v2TIMImage != null) {
            return v2TIMImage.getWidth();
        }
        return 0;
    }

    public void downloadImage(String path, ImageDownloadCallback callback) {
        if (v2TIMImage != null) {
            v2TIMImage.downloadImage(path, new V2TIMDownloadCallback() {
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


    public interface ImageDownloadCallback {
        void onProgress(long currentSize, long totalSize);

        void onSuccess();

        void onError(int code, String desc);
    }
}
