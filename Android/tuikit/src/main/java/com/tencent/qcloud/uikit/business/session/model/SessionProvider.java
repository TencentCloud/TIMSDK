package com.tencent.qcloud.uikit.business.session.model;


import com.tencent.qcloud.uikit.api.session.ISessionAdapter;
import com.tencent.qcloud.uikit.api.session.ISessionProvider;

import java.util.ArrayList;
import java.util.List;


public class SessionProvider implements ISessionProvider {

    private ArrayList<SessionInfo> dataSource = new ArrayList();
    private ISessionAdapter adapter;

    @Override
    public List<SessionInfo> getDataSource() {
        return dataSource;
    }

    /**
     * 设置会话数据源
     *
     * @param dataSource
     */
    public void setDataSource(ArrayList<SessionInfo> dataSource) {
        this.dataSource.clear();
        this.dataSource.addAll(dataSource);
        updateAdapter();
    }


    /**
     * 批量添加会话数据
     *
     * @param sessions 会话数据集合
     * @return
     */
    @Override
    public boolean addSessions(List<SessionInfo> sessions) {
        if (sessions.size() == 1) {
            SessionInfo session = sessions.get(0);
            for (int i = 0; i < dataSource.size(); i++) {
                if (dataSource.get(i).getPeer().equals(session.getPeer()))
                    return true;
            }
        }
        boolean flag = dataSource.addAll(sessions);
        if (flag)
            updateAdapter();
        return flag;
    }

    /**
     * 批量删除会话数据
     *
     * @param sessions 会话数据集合
     * @return
     */
    @Override
    public boolean deleteSessions(List<SessionInfo> sessions) {
        List<Integer> removeIndexs = new ArrayList();
        for (int i = 0; i < dataSource.size(); i++) {
            for (int j = 0; j < sessions.size(); j++) {
                if (dataSource.get(i).getPeer().equals(sessions.get(j).getPeer())) {
                    removeIndexs.add(i);
                    sessions.remove(j);
                    break;
                }
            }

        }
        if (removeIndexs.size() > 0) {
            for (int i = 0; i < removeIndexs.size(); i++) {
                dataSource.remove(removeIndexs.get(i));
            }
            updateAdapter();
            return true;
        }
        return false;
    }

    /**
     * 删除单个会话数据
     *
     * @param index 会话在数据源集合的索引
     * @return
     */
    public void deleteSession(int index) {
        if (dataSource.remove(index) != null) {
            updateAdapter();
        }

    }

    /**
     * 删除单个会话数据
     *
     * @param peer 会话ID
     * @return
     */
    public void deleteSession(String peer) {
        for (int i = 0; i < dataSource.size(); i++) {
            if (dataSource.get(i).getPeer().equals(peer)) {
                if (dataSource.remove(i) != null) {
                    updateAdapter();
                }
                return;
            }
        }
    }

    /**
     * 批量更新会话
     *
     * @param sessions 会话数据集合
     * @return
     */
    @Override
    public boolean updateSessions(List<SessionInfo> sessions) {
        boolean flag = false;
        for (int i = 0; i < dataSource.size(); i++) {
            for (int j = 0; j < sessions.size(); j++) {
                SessionInfo update = sessions.get(j);
                if (dataSource.get(i).getPeer().equals(update.getPeer())) {
                    dataSource.remove(i);
                    dataSource.add(i, update);
                    sessions.remove(j);
                    flag = true;
                    break;
                }
            }

        }
        if (flag) {
            updateAdapter();
            return true;
        } else {
            return false;
        }

    }

    /**
     * 清空会话
     */
    public void clear() {
        dataSource.clear();
        updateAdapter();
    }

    /**
     * 会话会话列界面，在数据源更新的地方调用
     */
    private void updateAdapter() {
        if (adapter != null)
            adapter.notifyDataSetChanged();
    }


    /**
     * 会话列表适配器绑定数据源是的回调
     *
     * @param adapter 会话UI显示适配器
     */
    @Override
    public void attachAdapter(ISessionAdapter adapter) {
        this.adapter = adapter;
    }
}
