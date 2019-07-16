package com.tencent.qcloud.tim.uikit.modules.conversation.interfaces;

import com.tencent.qcloud.tim.uikit.base.ILayout;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationListLayout;
import com.tencent.qcloud.tim.uikit.modules.conversation.base.ConversationInfo;

public interface IConversationLayout extends ILayout {

    /**
     * 获取会话列表List
     *
     * @return
     */
    ConversationListLayout getConversationList();

    /**
     * 置顶会话
     *
     * @param position     该item在列表的索引
     * @param conversation 会话内容
     */
    void setConversationTop(int position, ConversationInfo conversation);

    /**
     * 删除会话
     *
     * @param position     该item在列表的索引
     * @param conversation 会话内容
     */
    void deleteConversation(int position, ConversationInfo conversation);
}
