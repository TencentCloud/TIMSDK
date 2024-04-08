package com.tencent.qcloud.tuikit.timcommon.interfaces;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;

public interface ICommonMessageAdapter {
    TUIMessageBean getItem(int position);

    TUIMessageBean getFirstMessageBean();

    TUIMessageBean getLastMessageBean();

    void onItemRefresh(TUIMessageBean messageBean);

    UserFaceUrlCache getUserFaceUrlCache();
}
