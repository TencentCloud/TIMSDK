package com.tencent.qcloud.tim.tuikit.live.component.gift.imp;

public class GiftInfo {
    public static final int GIFT_TYPE_NORMAL = 0;
    public static final int GIFT_TYPE_SHOW_ANIMATION_PLAY = 1;
    // 礼物id
    public String giftId;
    //礼物图片对应的url
    public String giftPicUrl;
    //礼物全屏动画url
    public String lottieUrl;
    //礼物的名称
    public String title;
    //礼物价格
    public int price;
    //礼物类型 0为普通礼物， 1为播放全屏动画
    public int type;

    //礼物的选中状态
    public boolean isSelected;
    //礼物发送方名称
    public String sendUser;
    //礼物发送方头像
    public String sendUserHeadIcon;



    @Override
    public String toString() {
        return "GiftInfo{" +
                "giftId='" + giftId + '\'' +
                ", giftPicUrl='" + giftPicUrl + '\'' +
                ", title='" + title + '\'' +
                ", price=" + price +
                ", isSelected=" + isSelected +
                '}';
    }

    /**
     * 拷贝礼物基础属性
     * @return
     */
    public GiftInfo copy() {
        GiftInfo giftInfo = new GiftInfo();
        giftInfo.giftId = this.giftId;
        giftInfo.giftPicUrl = this.giftPicUrl;
        giftInfo.lottieUrl = this.lottieUrl;
        giftInfo.title = this.title;
        giftInfo.price = this.price;
        giftInfo.type = this.type;
        return giftInfo;
    }
}
