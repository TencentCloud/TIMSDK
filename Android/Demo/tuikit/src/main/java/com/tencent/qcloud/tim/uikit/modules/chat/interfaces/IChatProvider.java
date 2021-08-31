package com.tencent.qcloud.tim.uikit.modules.chat.interfaces;

import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageListAdapter;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;

import java.util.List;


public interface IChatProvider {

    /**
     * 获取聊天消息数据
     *
     * @return
     */
    List<MessageInfo> getDataSource();

    /**
     * 批量添加聊天消息
     *
     * @param messages 聊天消息
     * @param front    是否往前加（前：消息列表的头部，对应聊天界面的顶部，后：消息列表的尾部，对应聊天界面的底部）
     * @return
     */
    boolean addMessageList(List<MessageInfo> messages, boolean front);


    /**
     * 批量删除聊天消息
     *
     * @param messages 聊天消息
     * @return
     */
    boolean deleteMessageList(List<MessageInfo> messages);


    /**
     * 批量更新聊天消息
     *
     * @param messages 聊天消息
     * @return
     */
    boolean updateMessageList(List<MessageInfo> messages);


    /**
     * 绑定会话适配器时触发的调用
     *
     * @param adapter 会话UI显示适配器
     */
    void setAdapter(MessageListAdapter adapter);

}
