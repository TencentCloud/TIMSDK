package com.tencent.qcloud.uikit.api.chat;


import com.tencent.qcloud.uikit.business.chat.model.MessageInfo;

import java.util.List;

/**
 * Created by valexhuang on 2018/7/17.
 */

public interface IChatProvider {

    /**
     * 获取聊天消息数据
     *
     * @return
     */
    public List<MessageInfo> getDataSource();

    /**
     * 批量添加聊天消息
     *
     * @param messages 聊天消息
     * @param front    是否往前加（前：消息列表的头部，对应聊天界面的顶部，后：消息列表的尾部，对应聊天界面的底部）
     * @return
     */
    public boolean addMessageInfos(List<MessageInfo> messages, boolean front);


    /**
     * 批量删除聊天消息
     *
     * @param messages 聊天消息
     * @return
     */
    public boolean deleteMessageInfos(List<MessageInfo> messages);


    /**
     * 批量更新聊天消息
     *
     * @param messages 聊天消息
     * @return
     */
    public boolean updateMessageInfos(List<MessageInfo> messages);


    /**
     * 绑定会话适配器时触发的调用，在调用{@link com.tencent.qcloud.uikit.api.chat.IChatAdapter#setDataSource(IChatProvider)}时自动调用
     *
     * @param adapter 会话UI显示适配器
     */
    public void attachAdapter(IChatAdapter adapter);

}
