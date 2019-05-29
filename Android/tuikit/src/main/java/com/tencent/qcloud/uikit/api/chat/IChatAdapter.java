package com.tencent.qcloud.uikit.api.chat;

import android.support.v7.widget.RecyclerView;

import com.tencent.qcloud.uikit.business.chat.model.MessageInfo;


public abstract class IChatAdapter extends RecyclerView.Adapter {
    /**
     * 聊天数据源更新通知，通知聊天面板刷新界面
     *
     * @param type 变更类型
     * @param data 变更数据
     */
    public abstract void notifyDataSetChanged(int type, int data);

    /**
     * 设置聊天面板数据源 {@link com.tencent.qcloud.uikit.api.chat.IChatProvider}
     *
     * @param provider 聊天信息数据源
     */
    public abstract void setDataSource(IChatProvider provider);

    /**
     * 获取数据源中单个的聊天对象
     *
     * @param position
     * @return MessageInfo
     */
    public abstract MessageInfo getItem(int position);
}

