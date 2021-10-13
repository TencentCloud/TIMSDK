package com.tencent.qcloud.tim.uikit.live.component.gift;

import com.tencent.qcloud.tim.uikit.live.component.gift.imp.GiftInfo;

public interface GiftPanelDelegate {
    /**
     * 礼物点击事件
     */
    void onGiftItemClick(GiftInfo giftInfo);

    /**
     * 充值点击事件
     */
    void onChargeClick();
}
