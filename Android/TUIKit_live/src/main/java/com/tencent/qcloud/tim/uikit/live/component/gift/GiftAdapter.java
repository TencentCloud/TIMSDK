package com.tencent.qcloud.tim.uikit.live.component.gift;

public abstract class GiftAdapter {
    /**
     * 查询礼物信息
     * @param callback
     */
    public abstract void queryGiftInfoList(OnGiftListQueryCallback callback);
}
