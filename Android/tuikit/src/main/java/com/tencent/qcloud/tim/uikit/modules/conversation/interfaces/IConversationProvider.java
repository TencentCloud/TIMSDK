package com.tencent.qcloud.tim.uikit.modules.conversation.interfaces;

import com.tencent.qcloud.tim.uikit.modules.conversation.base.ConversationInfo;

import java.util.List;

/**
 * 会话列表数据源
 */

public interface IConversationProvider {

    /**
     * 获取具体的会话数据集合，ConversationContainer依据该数据集合展示会话列表
     *
     * @return
     */
    List<ConversationInfo> getDataSource();

    /**
     * 批量添加会话条目
     *
     * @param conversations 会话数据集合
     * @return
     */
    boolean addConversations(List<ConversationInfo> conversations);

    /**
     * 删除会话条目
     *
     * @param conversations 会话数据集合
     * @return
     */
    boolean deleteConversations(List<ConversationInfo> conversations);

    /**
     * 更新会话条目
     *
     * @param conversations 会话数据集合
     * @return
     */
    boolean updateConversations(List<ConversationInfo> conversations);


    /**
     * 绑定会话适配器时触发的调用，在调用{@link com.tencent.qcloud.tim.uikit.modules.conversation.interfaces.IConversationAdapter#setDataProvider}时自动调用
     *
     * @param adapter 会话UI显示适配器
     * @return
     */

    void attachAdapter(IConversationAdapter adapter);

}
