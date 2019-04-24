package com.tencent.qcloud.uikit.business.session.view.wedgit;


import com.tencent.qcloud.uikit.business.session.model.SessionInfo;

public interface SessionInterceptor {
    Object intercept(SessionInfo msg);
}
