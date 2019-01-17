package com.tencent.qcloud.uikit.api.infos;

import com.tencent.qcloud.uikit.business.chat.c2c.model.PersonalInfoBean;

/**
 * Created by valxehuang on 2018/7/30.
 */

public interface PersonalInfoPanelEvent {

    void onBackClick();

    void onBottomButtonClick(boolean isFriend, PersonalInfoBean info);

    void onAddFriendClick(PersonalInfoBean info);

    void onDelFriendClick(PersonalInfoBean info);

    void onAddToBlackListClick(PersonalInfoBean info);

}
