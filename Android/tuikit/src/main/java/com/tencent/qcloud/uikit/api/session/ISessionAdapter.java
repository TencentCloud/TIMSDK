package com.tencent.qcloud.uikit.api.session;

import android.widget.BaseAdapter;

import com.tencent.qcloud.uikit.business.session.model.SessionInfo;

/**
 * ISessionPanel(SessionListView) 的适配器，用户可自定义实现
 */

public abstract class ISessionAdapter extends BaseAdapter {
    /**
     * 设置适配器的数据源，该接口一般由ISessionPanel自动调用
     *
     * @param provider
     */
    public abstract void setDataProvider(ISessionProvider provider);

    /**
     * 获取适配器的条目数据，返回的是SessionInfo对象或其子对象
     *
     * @param position
     * @return SessionInfo
     */
    public abstract SessionInfo getItem(int position);

}
