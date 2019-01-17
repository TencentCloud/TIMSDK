package com.tencent.qcloud.uikit.business.session.view.wedgit;


import com.tencent.qcloud.uikit.business.session.model.SessionInfo;

/**
 * Created by valexhuang on 2018/8/27.
 */

public interface SessionInterceptor {
    Object intercept(SessionInfo msg);
}
