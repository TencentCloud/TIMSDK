package com.tencent.qcloud.tuikit.tuichat.bean;

import com.tencent.imsdk.v2.V2TIMFaceElem;
import com.tencent.imsdk.v2.V2TIMMessage;

public class FaceElemBean {
    private V2TIMFaceElem faceElem;

    public void setFaceElem(V2TIMFaceElem faceElem) {
        this.faceElem = faceElem;
    }

    public byte[] getData() {
        if (faceElem != null) {
            return faceElem.getData();
        } else {
            return new byte[0];
        }
    }

    public int getIndex() {
        if (faceElem != null) {
            return faceElem.getIndex();
        } else {
            return 0;
        }
    }

    public static FaceElemBean createFaceElemBean(MessageInfo messageInfo) {
        FaceElemBean faceElemBean = null;
        if (messageInfo != null) {
            V2TIMMessage message = messageInfo.getTimMessage();
            if (message != null) {
                if (message.getElemType() == V2TIMMessage.V2TIM_ELEM_TYPE_FACE) {
                    faceElemBean = new FaceElemBean();
                    faceElemBean.setFaceElem(message.getFaceElem());
                }
            }
        }
        return faceElemBean;
    }

}
