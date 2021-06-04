package com.tencent.qcloud.tim.uikit.base;

import android.view.ViewGroup;

import com.tencent.imsdk.v2.V2TIMMessage;

import java.util.List;

public interface TUIChatControllerListener {
    /**
     * 注册自定义 Action
     * @return
     */
    List<IBaseAction> onRegisterMoreActions();

    /**
     * 根据 V2TIMMessage 创建自定义消息元组类
     * @param timMessage
     * @return
     */
    IBaseInfo createCommonInfoFromTimMessage(V2TIMMessage timMessage);

    /**
     * 创建自定义 viewHolder
     * @param viewType
     * @param parent
     * @return true 表示成功创建，false 表示创建失败
     */
    IBaseViewHolder createCommonViewHolder(ViewGroup parent, int viewType);
    /**
     * 绘制自定义消息
     * @param baseViewHolder viewHolder
     * @param baseInfo 自定义消息
     * @param position
     * @return true 表示成功处理， false 表示无法处理
     */
    boolean bindCommonViewHolder(IBaseViewHolder baseViewHolder, IBaseInfo baseInfo, int position);

}
