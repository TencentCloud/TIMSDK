package com.tencent.qcloud.tuikit.tuichat.bean.message;

import android.net.Uri;
import android.text.TextUtils;

import com.tencent.imsdk.BaseConstants;
import com.tencent.imsdk.v2.V2TIMDownloadCallback;
import com.tencent.imsdk.v2.V2TIMElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.imsdk.v2.V2TIMVideoElem;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.util.FileUtil;
import com.tencent.qcloud.tuicore.util.ImageUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.VideoReplyQuoteBean;

import java.io.File;

public class VideoMessageBean extends TUIMessageBean {
    private String dataUri;
    private String dataPath;
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
        if (isSelf() && !TextUtils.isEmpty(videoEle.getSnapshotPath())) {
            int size[] = ImageUtil.getImageSize(videoEle.getSnapshotPath());
            imgWidth = size[0];
            imgHeight= size[1];
            dataPath = videoEle.getSnapshotPath();
            setDataUri(FileUtil.getUriFromPath(videoEle.getVideoPath()));
        } else {
            final String videoPath = TUIConfig.getVideoDownloadDir() + videoEle.getVideoUUID();
            Uri uri = Uri.parse(videoPath);
            setDataUri(uri);
            imgWidth = (int) videoEle.getSnapshotWidth();
            imgHeight = (int) videoEle.getSnapshotHeight();
            final String snapPath = TUIConfig.getImageDownloadDir() + videoEle.getSnapshotUUID();
            if (new File(snapPath).exists()) {
                dataPath = snapPath;
            }
        }

        if (v2TIMMessage.getElemType() == V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO) {
            videoElem = v2TIMMessage.getVideoElem();
        }
        setExtra(TUIChatService.getAppContext().getString(R.string.video_extra));
    }

    /**
     * 获取多媒体消息的数据源
     * 
     * Get the data source of the multimedia message
     *
     * @return
     */
    public Uri getDataUriObj() {
        if (!TextUtils.isEmpty(dataUri)) {
            return Uri.parse(dataUri);
        } else {
            return null;
        }
    }

    /**
     * 设置多媒体消息的数据源
     * 
     * Set the data source of the multimedia message
     *
     * @param dataUri
     */
    public void setDataUri(Uri dataUri) {
        if (dataUri != null) {
            this.dataUri = dataUri.toString();
        }
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

    public void getVideoUrl(final V2TIMValueCallback<String> callback) {
        if (callback == null) {
            return;
        }
        if (videoElem == null) {
            callback.onError(BaseConstants.ERR_INVALID_PARAMETERS, "elem is null");
            return;
        }

        videoElem.getVideoUrl(callback);
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

    @Override
    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return VideoReplyQuoteBean.class;
    }
}
