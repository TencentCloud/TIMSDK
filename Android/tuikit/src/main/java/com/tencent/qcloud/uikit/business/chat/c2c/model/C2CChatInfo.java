package com.tencent.qcloud.uikit.business.chat.c2c.model;

import com.tencent.imsdk.TIMConversationType;
import com.tencent.qcloud.uikit.business.chat.model.BaseChatInfo;

/**
 * Created by valexhuang on 2018/8/21.
 */

public class C2CChatInfo extends BaseChatInfo {

    public C2CChatInfo() {
        setType(TIMConversationType.C2C);
    }

}
