package com.tencent.qcloud.uikit.business.mine.presenter;

import com.tencent.qcloud.uikit.business.chat.c2c.model.SelfInfoManager;
import com.tencent.qcloud.uikit.business.mine.view.SelfInfoPanel;

public class SelfInfoPresenter {

    private SelfInfoManager manager = SelfInfoManager.getInstance();
    private SelfInfoPanel mSelfPanel;

    public SelfInfoPresenter(SelfInfoPanel panel) {
        mSelfPanel = panel;

    }

}
