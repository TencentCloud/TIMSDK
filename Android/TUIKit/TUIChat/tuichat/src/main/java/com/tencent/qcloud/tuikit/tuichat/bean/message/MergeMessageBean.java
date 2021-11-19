package com.tencent.qcloud.tuikit.tuichat.bean.message;

import com.tencent.imsdk.v2.V2TIMMergerElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;

import java.util.ArrayList;
import java.util.List;

public class MergeMessageBean extends TUIMessageBean {
    private V2TIMMergerElem mergerElem;

    @Override
    public String onGetDisplayString() {
        return getExtra();
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        // 合并转发消息
        mergerElem = v2TIMMessage.getMergerElem();
        setExtra(TUIChatService.getAppContext().getString(R.string.forward_extra));
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

}
