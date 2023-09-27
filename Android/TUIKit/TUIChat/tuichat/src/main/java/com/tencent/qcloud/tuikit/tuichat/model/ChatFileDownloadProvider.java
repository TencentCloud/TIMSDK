package com.tencent.qcloud.tuikit.tuichat.model;

import com.tencent.imsdk.v2.V2TIMDownloadCallback;
import com.tencent.imsdk.v2.V2TIMElem;
import com.tencent.imsdk.v2.V2TIMFileElem;
import com.tencent.imsdk.v2.V2TIMImageElem;
import com.tencent.imsdk.v2.V2TIMSoundElem;
import com.tencent.imsdk.v2.V2TIMVideoElem;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IDownloadProvider;

public class ChatFileDownloadProvider implements IDownloadProvider {
    private TUIMessageBean messageBean;
    private ImageMessageBean.ImageBean imageBean;

    public ChatFileDownloadProvider(TUIMessageBean messageBean) {
        this.messageBean = messageBean;
    }

    public ChatFileDownloadProvider(ImageMessageBean.ImageBean imageBean) {
        this.imageBean = imageBean;
    }

    @Override
    public void downloadSound(String path, TUIValueCallback callback) {
        if (messageBean == null || messageBean.getV2TIMMessage() == null || messageBean.getV2TIMMessage().getSoundElem() == null) {
            return;
        }
        V2TIMSoundElem soundElem = messageBean.getV2TIMMessage().getSoundElem();
        soundElem.downloadSound(path, new DownloadCallback(callback));
    }

    @Override
    public void downloadFile(String path, TUIValueCallback callback) {
        if (messageBean == null || messageBean.getV2TIMMessage() == null || messageBean.getV2TIMMessage().getFileElem() == null) {
            return;
        }
        V2TIMFileElem fileElem = messageBean.getV2TIMMessage().getFileElem();
        fileElem.downloadFile(path, new DownloadCallback(callback));
    }

    @Override
    public void downloadVideo(String path, TUIValueCallback callback) {
        if (messageBean == null || messageBean.getV2TIMMessage() == null || messageBean.getV2TIMMessage().getVideoElem() == null) {
            return;
        }
        V2TIMVideoElem videoElem = messageBean.getV2TIMMessage().getVideoElem();
        videoElem.downloadVideo(path, new DownloadCallback(callback));
    }

    @Override
    public void downloadVideoSnapshot(String path, TUIValueCallback callback) {
        if (messageBean == null || messageBean.getV2TIMMessage() == null || messageBean.getV2TIMMessage().getVideoElem() == null) {
            return;
        }
        V2TIMVideoElem videoElem = messageBean.getV2TIMMessage().getVideoElem();
        if (videoElem == null) {
            return;
        }
        videoElem.downloadSnapshot(path, new DownloadCallback(callback));
    }

    @Override
    public void downloadImage(String path, TUIValueCallback callback) {
        if (imageBean == null || imageBean.getV2TIMImage() == null) {
            return;
        }
        V2TIMImageElem.V2TIMImage imageElem = imageBean.getV2TIMImage();
        imageElem.downloadImage(path, new DownloadCallback(callback));
    }

    private static class DownloadCallback implements V2TIMDownloadCallback {
        private TUIValueCallback callback;

        DownloadCallback(TUIValueCallback callback) {
            this.callback = callback;
        }

        @Override
        public void onSuccess() {
            TUIValueCallback.onSuccess(callback, null);
        }

        @Override
        public void onError(int code, String desc) {
            TUIValueCallback.onError(callback, code, desc);
        }

        @Override
        public void onProgress(V2TIMElem.V2ProgressInfo progressInfo) {
            TUIValueCallback.onProgress(callback, progressInfo.getCurrentSize(), progressInfo.getTotalSize());
        }
    }

    public static String getSoundSelfPath(SoundMessageBean soundMessageBean) {
        if (soundMessageBean != null && soundMessageBean.getV2TIMMessage() != null && soundMessageBean.getV2TIMMessage().getSoundElem() != null) {
            if (soundMessageBean.isSelf()) {
                return soundMessageBean.getV2TIMMessage().getSoundElem().getPath();
            }
        }
        return null;
    }

    public static String getFileSelfPath(FileMessageBean fileMessageBean) {
        if (fileMessageBean != null && fileMessageBean.getV2TIMMessage() != null && fileMessageBean.getV2TIMMessage().getFileElem() != null) {
            if (fileMessageBean.isSelf()) {
                return fileMessageBean.getV2TIMMessage().getFileElem().getPath();
            }
        }
        return null;
    }

    public static String getVideoSelfPath(VideoMessageBean videoMessageBean) {
        if (videoMessageBean != null && videoMessageBean.getV2TIMMessage() != null && videoMessageBean.getV2TIMMessage().getVideoElem() != null) {
            if (videoMessageBean.isSelf()) {
                return videoMessageBean.getV2TIMMessage().getVideoElem().getVideoPath();
            }
        }
        return null;
    }

    public static String getVideoSnapshotSelfPath(VideoMessageBean videoMessageBean) {
        if (videoMessageBean != null && videoMessageBean.getV2TIMMessage() != null && videoMessageBean.getV2TIMMessage().getVideoElem() != null) {
            if (videoMessageBean.isSelf()) {
                return videoMessageBean.getV2TIMMessage().getVideoElem().getSnapshotPath();
            }
        }
        return null;
    }

    public static String getImageSelfPath(ImageMessageBean imageMessageBean) {
        if (imageMessageBean != null && imageMessageBean.getV2TIMMessage() != null && imageMessageBean.getV2TIMMessage().getImageElem() != null) {
            if (imageMessageBean.isSelf()) {
                return imageMessageBean.getV2TIMMessage().getImageElem().getPath();
            }
        }
        return null;
    }

    public static String getSoundUUID(SoundMessageBean soundMessageBean) {
        if (soundMessageBean != null && soundMessageBean.getV2TIMMessage() != null && soundMessageBean.getV2TIMMessage().getSoundElem() != null) {
            return soundMessageBean.getV2TIMMessage().getSoundElem().getUUID();
        }
        return null;
    }

    public static String getFileUUID(FileMessageBean fileMessageBean) {
        if (fileMessageBean != null && fileMessageBean.getV2TIMMessage() != null && fileMessageBean.getV2TIMMessage().getFileElem() != null) {
            return fileMessageBean.getV2TIMMessage().getFileElem().getUUID();
        }
        return null;
    }

    public static String getFileName(FileMessageBean fileMessageBean) {
        if (fileMessageBean != null && fileMessageBean.getV2TIMMessage() != null && fileMessageBean.getV2TIMMessage().getFileElem() != null) {
            return fileMessageBean.getV2TIMMessage().getFileElem().getFileName();
        }
        return null;
    }

    public static String getVideoUUID(VideoMessageBean videoMessageBean) {
        if (videoMessageBean != null && videoMessageBean.getV2TIMMessage() != null && videoMessageBean.getV2TIMMessage().getVideoElem() != null) {
            return videoMessageBean.getV2TIMMessage().getVideoElem().getVideoUUID();
        }
        return null;
    }

    public static String getVideoSnapshotUUID(VideoMessageBean videoMessageBean) {
        if (videoMessageBean != null && videoMessageBean.getV2TIMMessage() != null && videoMessageBean.getV2TIMMessage().getVideoElem() != null) {
            return videoMessageBean.getV2TIMMessage().getVideoElem().getSnapshotUUID();
        }
        return null;
    }

    public static String getImageUUID(ImageMessageBean.ImageBean imageBean) {
        if (imageBean != null && imageBean.getV2TIMImage() != null) {
            return imageBean.getV2TIMImage().getUUID();
        }
        return null;
    }
}
