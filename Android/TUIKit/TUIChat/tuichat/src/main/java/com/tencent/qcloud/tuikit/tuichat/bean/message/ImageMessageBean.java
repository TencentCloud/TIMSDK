package com.tencent.qcloud.tuikit.tuichat.bean.message;

import com.tencent.imsdk.v2.V2TIMImageElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.ImageReplyQuoteBean;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class ImageMessageBean extends TUIMessageBean {
    /**
     *
     * original image
     */
    public static final int IMAGE_TYPE_ORIGIN = V2TIMImageElem.V2TIM_IMAGE_TYPE_ORIGIN;
    /**
     *
     * thumbnail
     */
    public static final int IMAGE_TYPE_THUMB = V2TIMImageElem.V2TIM_IMAGE_TYPE_THUMB;
    /**
     *
     * big picture
     */
    public static final int IMAGE_TYPE_LARGE = V2TIMImageElem.V2TIM_IMAGE_TYPE_LARGE;

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
                if (imageBean.getType() == IMAGE_TYPE_THUMB) {
                    imgWidth = imageBean.getWidth();
                    imgHeight = imageBean.getHeight();
                }
            }
            this.imageBeanList = imageBeans;
        }
        setExtra(TUIChatService.getAppContext().getString(R.string.picture_extra));
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

    public List<ImageBean> getImageBeanList() {
        return imageBeanList;
    }

    public ImageBean getImageBean(int type) {
        for (ImageBean imageBean : imageBeanList) {
            if (imageBean.getType() == type) {
                return imageBean;
            }
        }
        return null;
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
    }

    @Override
    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return ImageReplyQuoteBean.class;
    }
}
