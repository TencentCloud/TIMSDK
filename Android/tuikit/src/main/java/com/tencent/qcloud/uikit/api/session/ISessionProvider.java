package com.tencent.qcloud.uikit.api.session;

import com.tencent.qcloud.uikit.business.session.model.SessionInfo;
import com.tencent.qcloud.uikit.business.session.view.wedgit.SessionAdapter;

import java.util.List;

/**
 * Created by valexhuang on 2018/7/17.
 * 会话列表数据源
 */

public interface ISessionProvider {

    /**
     * 获取具体的会话数据集合，SessionPanel依据该数据集合展示会话列表
     *
     * @return
     */
    public List<SessionInfo> getDataSource();

    /**
     * 批量添加会话条目
     *
     * @param sessions 会话数据集合
     * @return
     */
    public boolean addSessions(List<SessionInfo> sessions);

    /**
     * 删除会话条目
     *
     * @param sessions 会话数据集合
     * @return
     */
    public boolean deleteSessions(List<SessionInfo> sessions);

    /**
     * 更新会话条目
     *
     * @param sessions 会话数据集合
     * @return
     */
    public boolean updateSessions(List<SessionInfo> sessions);


    /**
     * 绑定会话适配器时触发的调用，在调用{@link com.tencent.qcloud.uikit.api.session.ISessionAdapter#setDataProvider}时自动调用
     *
     * @param adapter 会话UI显示适配器
     * @return
     */

    public void attachAdapter(ISessionAdapter adapter);

}
