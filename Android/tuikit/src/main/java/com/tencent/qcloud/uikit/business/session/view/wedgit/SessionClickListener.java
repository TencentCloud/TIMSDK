package com.tencent.qcloud.uikit.business.session.view.wedgit;


import com.tencent.qcloud.uikit.business.session.model.SessionInfo;

public interface SessionClickListener {

    /**
     * 会话列表点击事件回调
     *
     * @param session 具体的SessionInfo对象
     */
    void onSessionClick(SessionInfo session);


}
