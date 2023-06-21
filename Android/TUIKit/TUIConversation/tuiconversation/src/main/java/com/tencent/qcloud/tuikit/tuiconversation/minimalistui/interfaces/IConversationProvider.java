package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.interfaces;

import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.interfaces.IConversationListAdapter;

import java.util.List;

public interface IConversationProvider {
    /**
     * 获取具体的会话数据集合，ConversationContainer依据该数据集合展示会话列表
     *
     * Get a specific session data set, and ConversationContainer displays the session list based on the data set
     *
     * @return
     */
    List<ConversationInfo> getDataSource();

    /**
     * 批量添加会话条目
     *
     * Bulk add session entries
     *
     * @param conversations 会话数据集合
     * @return
     */
    boolean addConversations(List<ConversationInfo> conversations);

    /**
     * 删除会话条目
     *
     * Delete session entries
     *
     * @param conversations 会话数据集合
     * @return
     */
    boolean deleteConversations(List<ConversationInfo> conversations);

    /**
     * 更新会话条目
     *
     * Update session entries
     *
     * @param conversations 会话数据集合
     * @return
     */
    boolean updateConversations(List<ConversationInfo> conversations);

    /**
     * 绑定会话适配器时触发的调用，在调用{@link com.tencent.qcloud.tuikit.tuiconversation.interfaces.IConversationListAdapter#setDataProvider}时自动调用
     *
     * Called when a session adapter is bound, automatically called when {@link
     * com.tencent.qcloud.tuikit.tuiconversation.interfaces.IConversationListAdapter#setDataProvider} is called
     *
     * @param adapter 会话UI显示适配器
     * @return
     */

    void attachAdapter(IConversationListAdapter adapter);
}
