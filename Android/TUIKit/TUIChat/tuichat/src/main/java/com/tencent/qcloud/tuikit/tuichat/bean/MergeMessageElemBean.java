package com.tencent.qcloud.tuikit.tuichat.bean;

import com.tencent.imsdk.v2.V2TIMMergerElem;
import com.tencent.imsdk.v2.V2TIMMessage;

import java.util.ArrayList;
import java.util.List;

public class MergeMessageElemBean {
    private V2TIMMergerElem mergerElem;

    public void setMergerElem(V2TIMMergerElem mergerElem) {
        this.mergerElem = mergerElem;
    }

    public V2TIMMergerElem getMergerElem() {
        return mergerElem;
    }

    public String getTitle() {
        if (mergerElem != null) {
            return mergerElem.getTitle();
        }
        return "";
    }

    public List<String> getAbstractList() {
        if (mergerElem != null) {
            return mergerElem.getAbstractList();
        }
        return new ArrayList<>();
    }

    public boolean isLayersOverLimit() {
        if (mergerElem != null) {
            return mergerElem.isLayersOverLimit();
        }
        return false;
    }

    public static MergeMessageElemBean createMergeMessageElemBean(MessageInfo messageInfo) {
        MergeMessageElemBean mergeMessageElemBean = null;
        if (messageInfo != null) {
            V2TIMMessage message = messageInfo.getTimMessage();
            if (message != null) {
                if (message.getElemType() == V2TIMMessage.V2TIM_ELEM_TYPE_MERGER) {
                    mergeMessageElemBean = new MergeMessageElemBean();
                    V2TIMMergerElem mergerElem = message.getMergerElem();
                    mergeMessageElemBean.setMergerElem(mergerElem);
                }
            }
        }
        return mergeMessageElemBean;
    }
}
