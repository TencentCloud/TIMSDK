package com.tencent.qcloud.uikit.business.chat.c2c.model;

import com.tencent.qcloud.uikit.common.IUIKitCallBack;


public class SelfInfoManager {

    private static final SelfInfoManager instance = new SelfInfoManager();

    private SelfInfoManager() {
    }

    public static SelfInfoManager getInstance() {
        return instance;
    }

    public void modifyNickName(String nickName, IUIKitCallBack callBack) {

    }

    public void modifySignature(String signature, IUIKitCallBack callBack) {

    }

    public void modifyBirthday() {

    }
}
