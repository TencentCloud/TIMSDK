package com.tencent.qcloud.tuikit.tuichat.bean.message;

import android.net.Uri;
import android.text.TextUtils;
import com.tencent.imsdk.v2.V2TIMDownloadCallback;
import com.tencent.imsdk.v2.V2TIMElem;
import com.tencent.imsdk.v2.V2TIMImageElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.timcommon.util.ImageUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.ImageReplyQuoteBean;
import java.io.File;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class ImageMessageBean extends TUIMessageBean {
    /**
     * ## 原图
     *
     * original image
     */
    public static final int IMAGE_TYPE_ORIGIN = V2TIMImageElem.V2TIM_IMAGE_TYPE_ORIGIN;
    /**
     * ## 缩略图
     *
     * thumbnail
     */
    public static final int IMAGE_TYPE_THUMB = V2TIMImageElem.V2TIM_IMAGE_TYPE_THUMB;
    /**
     * ## 大图
     *
     * big picture
     */
    public static final int IMAGE_TYPE_LARGE = V2TIMImageElem.V2TIM_IMAGE_TYPE_LARGE;

    private String dataUri;
    private String dataPath;
    private int imgWidth;
    private int imgHeight;

    private V2TIMImageElem imageElem;
    private List<ImageBean> imageBeanList;

    @Override
    public String onGetDisplayString() {
        return getExtra();
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        imageElem = v2TIMMessage.getImageElem();

        List<V2TIMImageElem.V2TIMImage> imageList = imageElem.getImageList();
        if (imageList != null) {
            List<ImageBean> imageBeans = new ArrayList<>();
            for (V2TIMImageElem.V2TIMImage v2TIMImage : imageList) {
                ImageBean imageBean = new ImageBean();
                imageBean.setV2TIMImage(v2TIMImage);
                imageBeans.add(imageBean);
            }
            this.imageBeanList = imageBeans;
        }

        String localPath = imageElem.getPath();
        if (isSelf() && !TextUtils.isEmpty(localPath) && new File(localPath).exists()) {
            dataPath = localPath;
            int[] size = ImageUtil.getImageSize(localPath);
            imgWidth = size[0];
            imgHeight = size[1];
        }
        // 本地路径为空，可能为更换手机或者是接收的消息
        // The local path is empty, it may be a phone change or a received message
        else {
            List<V2TIMImageElem.V2TIMImage> imgs = imageElem.getImageList();
            for (int i = 0; i < imgs.size(); i++) {
                V2TIMImageElem.V2TIMImage img = imgs.get(i);
                if (img.getType() == V2TIMImageElem.V2TIM_IMAGE_TYPE_ORIGIN) {
                    imgWidth = img.getWidth();
                    imgHeight = img.getHeight();
                }
                if (img.getType() == V2TIMImageElem.V2TIM_IMAGE_TYPE_THUMB) {
                    final String path = ImageUtil.generateImagePath(img.getUUID(), V2TIMImageElem.V2TIM_IMAGE_TYPE_THUMB);
                    File file = new File(path);
                    if (file.exists()) {
                        dataPath = path;
                    }
                }
            }
        }
        setExtra(TUIChatService.getAppContext().getString(R.string.picture_extra));
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

    public void setImageElem(V2TIMImageElem imageElem) {
        this.imageElem = imageElem;
    }

    public void setImageBeanList(List<ImageBean> imageBeanList) {
        this.imageBeanList = imageBeanList;
    }

    public List<ImageBean> getImageBeanList() {
        return imageBeanList;
    }

    public String getPath() {
        if (imageElem != null) {
            return imageElem.getPath();
        }
        return "";
    }

    public static class ImageBean implements Serializable {
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
            return IMAGE_TYPE_THUMB;
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

    @Override
    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return ImageReplyQuoteBean.class;
    }
}
