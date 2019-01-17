package com.tencent.qcloud.uikit.business.session.view.wedgit;

import android.view.View;

import com.tencent.qcloud.uikit.business.session.model.SessionInfo;

/**
 * Created by valxehuang on 2018/7/17.
 */

public interface SessionClickListener {

    /**
     * 会话列表点击事件回调
     *
     * @param session 具体的SessionInfo对象
     */
    void onSessionClick(SessionInfo session);


}
