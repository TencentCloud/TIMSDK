package com.tencent.qcloud.uikit.business.chat.c2c.view.widget;

import java.util.Date;

public interface SelfInfoPanelEvent {

    void onModifyNickNameClick(String nickName);

    void onModifySignatureClick(String signature);

    void onModifyBirthdayClick(Date date);
}
