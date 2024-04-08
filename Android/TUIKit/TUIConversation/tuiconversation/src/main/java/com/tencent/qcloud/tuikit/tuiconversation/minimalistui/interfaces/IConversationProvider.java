package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.interfaces;

import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.interfaces.IConversationListAdapter;

import java.util.List;

public interface IConversationProvider {
    /**
     * Get a specific session data set, and ConversationContainer displays the session list based on the data set
     *
     * @return
     */
    List<ConversationInfo> getDataSource();

    /**
     * Bulk add session entries
     *
     * @param conversations 
     * @return
     */
    boolean addConversations(List<ConversationInfo> conversations);

    /**
     * Delete session entries
     *
     * @param conversations 
     * @return
     */
    boolean deleteConversations(List<ConversationInfo> conversations);

    /**
     * Update session entries
     *
     * @param conversations 
     * @return
     */
    boolean updateConversations(List<ConversationInfo> conversations);

    /**
     * Called when a session adapter is bound, automatically called when {@link
     * com.tencent.qcloud.tuikit.tuiconversation.interfaces.IConversationListAdapter#setDataProvider} is called
     *
     * @param adapter UI
     * @return
     */

    void attachAdapter(IConversationListAdapter adapter);
}
