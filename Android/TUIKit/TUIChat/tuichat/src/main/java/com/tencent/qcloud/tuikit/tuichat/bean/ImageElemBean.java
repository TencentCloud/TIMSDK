package com.tencent.qcloud.tuikit.tuichat.bean;

import com.tencent.imsdk.v2.V2TIMImageElem;
import com.tencent.imsdk.v2.V2TIMMessage;

import java.util.ArrayList;
import java.util.List;

public class ImageElemBean {
    /**
     * ## 原图
     */
    public static final int IMAGE_TYPE_ORIGIN = V2TIMImageElem.V2TIM_IMAGE_TYPE_ORIGIN;
    /**
     * ## 缩略图
     */
    public static final int IMAGE_TYPE_THUMB = V2TIMImageElem.V2TIM_IMAGE_TYPE_THUMB;
    /**
     * ## 大图
     */
    public static final int IMAGE_TYPE_LARGE = V2TIMImageElem.V2TIM_IMAGE_TYPE_LARGE;

    private V2TIMImageElem imageElem;

    private List<ImageBean> imageBeanList;

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
        if(imageElem != null) {
            return imageElem.getPath();
        }
        return "";
    }

    public static ImageElemBean createImageElemBean(MessageInfo messageInfo) {
        ImageElemBean imageElemBean = null;
        if (messageInfo != null) {
            V2TIMMessage message = messageInfo.getTimMessage();
            if (message != null) {
                if (message.getElemType() == V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE) {
                    imageElemBean = new ImageElemBean();
                    V2TIMImageElem imageElem = message.getImageElem();
                    imageElemBean.setImageElem(imageElem);
                    List<V2TIMImageElem.V2TIMImage> imageList = imageElem.getImageList();
                    if (imageList != null) {
                        List<ImageBean> imageBeans = new ArrayList<>();
                        for(V2TIMImageElem.V2TIMImage v2TIMImage : imageList) {
                            ImageBean imageBean = new ImageBean();
                            imageBean.setV2TIMImage(v2TIMImage);
                            imageBeans.add(imageBean);
                        }
                        imageElemBean.setImageBeanList(imageBeans);
                    }
                }
            }
        }
        return imageElemBean;
    }
}
