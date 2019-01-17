package com.tencent.qcloud.uikit.business.chat.c2c.model;

import com.tencent.qcloud.uikit.common.IUIKitCallBack;

/**
 * Created by valxehuang on 2018/7/30.
 */

public class PersonalInfoManager {

    private static PersonalInfoManager instance = new PersonalInfoManager();

    public static PersonalInfoManager getInstance() {
        return instance;
    }

    private PersonalInfoManager() {
    }

    public void addFriend(PersonalInfoBean info, IUIKitCallBack callBack) {

    }

    public void delFriend(PersonalInfoBean info, IUIKitCallBack callBack) {

    }

    public void addToBlackList(PersonalInfoBean info, IUIKitCallBack callBack) {

    }
}
