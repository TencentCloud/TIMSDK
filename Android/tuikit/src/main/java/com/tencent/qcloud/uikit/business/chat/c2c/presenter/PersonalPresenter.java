package com.tencent.qcloud.uikit.business.chat.c2c.presenter;

import com.tencent.qcloud.uikit.common.IUIKitCallBack;
import com.tencent.qcloud.uikit.api.infos.IPersonalInfoPanel;
import com.tencent.qcloud.uikit.business.chat.c2c.model.PersonalInfoBean;
import com.tencent.qcloud.uikit.business.chat.c2c.model.PersonalInfoManager;


public class PersonalPresenter {

    private IPersonalInfoPanel mInfoPanel;
    private PersonalInfoManager mManager = PersonalInfoManager.getInstance();

    public PersonalPresenter(IPersonalInfoPanel infoPanel) {
        this.mInfoPanel = infoPanel;
    }

    public void initPersonalInfo(PersonalInfoBean info) {
        mInfoPanel.initPersonalInfo(info);
    }

    public void addFriend(PersonalInfoBean info) {
        mManager.addFriend(info, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {

            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
    }


    public void delFriend(PersonalInfoBean info) {
        mManager.delFriend(info, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {

            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
    }

    public void addToBlackList(PersonalInfoBean info) {
        mManager.addToBlackList(info, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {

            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
    }
}
