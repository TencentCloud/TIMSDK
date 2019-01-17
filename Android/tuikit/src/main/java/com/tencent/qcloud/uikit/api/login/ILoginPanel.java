package com.tencent.qcloud.uikit.api.login;

import com.tencent.qcloud.uikit.business.login.view.ILoginEvent;

/**
 * Created by valexhuang on 2018/7/2.
 */

public interface ILoginPanel {
    /**
     * 设置登录界面事件监听{@link com.tencent.qcloud.uikit.business.login.view.ILoginEvent}
     *
     * @param event
     */
    public void setLoginEvent(ILoginEvent event);
}
