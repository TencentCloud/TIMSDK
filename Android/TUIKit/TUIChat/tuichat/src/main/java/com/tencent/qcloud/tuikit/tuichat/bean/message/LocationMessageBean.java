package com.tencent.qcloud.tuikit.tuichat.bean.message;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.LocationReplyQuoteBean;

public class LocationMessageBean extends TUIMessageBean {
    private String desc;
    private double latitude;
    private double longitude;

    @Override
    public String onGetDisplayString() {
        return desc;
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        desc = v2TIMMessage.getLocationElem().getDesc();
        longitude = v2TIMMessage.getLocationElem().getLongitude();
        latitude = v2TIMMessage.getLocationElem().getLatitude();
    }

    public double getLatitude() {
        return latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public String getDesc() {
        return desc;
    }

    @Override
    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return LocationReplyQuoteBean.class;
    }
}
