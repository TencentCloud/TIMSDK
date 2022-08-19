package com.tencent.qcloud.tuikit.tuiconversation;

import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;

import java.util.Map;

public interface ITUIConversationService extends ITUIService, ITUINotification {

    /**
     * 1、获取会话是否置顶；
     * @param method TUIConstants.TUIConversation.METHOD_IS_TOP_CONVERSATION
     * @param param {TUIConstants.TUIConversation.CHAT_ID : String}
     * @return {TUIConstants.TUIConversation.IS_TOP : Boolean}
     * 2、设置会话置顶；
     * @param method TUIConstants.TUIConversation.METHOD_SET_TOP_CONVERSATION
     * @param param {TUIConstants.TUIConversation.CHAT_ID : String, TUIConstants.TUIConversation.IS_SET_TOP : Boolean}
     * 3、获取未读总数；
     * @param method TUIConstants.TUIConversation.METHOD_GET_TOTAL_UNREAD_COUNT
     * @return 未读总数
     * 4、更新未读总数；
     * @param method TUIConstants.TUIConversation.METHOD_UPDATE_TOTAL_UNREAD_COUNT
     * 5、删除会话。
     * @param method TUIConstants.TUIConversation.METHOD_DELETE_CONVERSATION
     * @param param {TUIConstants.TUIConversation.CONVERSATION_ID : String}
     * 
     * 
     * 1、Get whether the conversation is sticky
     * @param method TUIConstants.TUIConversation.METHOD_IS_TOP_CONVERSATION
     * @param param {TUIConstants.TUIConversation.CHAT_ID : String}
     * @return {TUIConstants.TUIConversation.IS_TOP : Boolean}
     * 2、Set session sticky
     * @param method TUIConstants.TUIConversation.METHOD_SET_TOP_CONVERSATION
     * @param param {TUIConstants.TUIConversation.CHAT_ID : String, TUIConstants.TUIConversation.IS_SET_TOP : Boolean}
     * 3、Get the total number of unreads
     * @param method TUIConstants.TUIConversation.METHOD_GET_TOTAL_UNREAD_COUNT
     * @return the total number of unreads
     * 4、Update the total number of unreads
     * @param method TUIConstants.TUIConversation.METHOD_UPDATE_TOTAL_UNREAD_COUNT
     * 5、Delete conversation
     * @param method TUIConstants.TUIConversation.METHOD_DELETE_CONVERSATION
     * @param param {TUIConstants.TUIConversation.CONVERSATION_ID : String}
     */
    @Override
    Object onCall(String method, Map<String, Object> param);

    /**
     * 1、接收退群通知；
     * @param key TUIConstants.TUIGroup.EVENT_GROUP
     * @param subKey TUIConstants.TUIGroup.EVENT_SUB_KEY_EXIT_GROUP,
     *               TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_DISMISS,
     *               TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_RECYCLE
     * @param param {TUIConstants.TUIGroup.GROUP_ID : String}
     * 2、接收群成员退出群通知：
     * @param key TUIConstants.TUIGroup.EVENT_GROUP
     * @param subKey TUIConstants.TUIGroup.EVENT_SUB_KEY_MEMBER_KICKED_GROUP
     * @param param {TUIConstants.TUIGroup.GROUP_ID : String, TUIConstants.TUIGroup.GROUP_MEMBER_ID_LIST : ArrayList<String>}
     * 3、接收好友备注修改通知。
     * @param key TUIConstants.TUIContact.EVENT_FRIEND_INFO_CHANGED
     * @param subKey TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_REMARK_CHANGED
     * @param param {TUIConstants.TUIContact.FRIEND_ID : String, TUIConstants.TUIContact.FRIEND_REMARK : String}
     * 
     * 
     * 1、Receive notifications of exit group
     * @param key TUIConstants.TUIGroup.EVENT_GROUP
     * @param subKey TUIConstants.TUIGroup.EVENT_SUB_KEY_EXIT_GROUP,
     *               TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_DISMISS,
     *               TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_RECYCLE
     * @param param {TUIConstants.TUIGroup.GROUP_ID : String}
     * 2、Receive group members leaving the group notification
     * @param key TUIConstants.TUIGroup.EVENT_GROUP
     * @param subKey TUIConstants.TUIGroup.EVENT_SUB_KEY_MEMBER_KICKED_GROUP
     * @param param {TUIConstants.TUIGroup.GROUP_ID : String, TUIConstants.TUIGroup.GROUP_MEMBER_ID_LIST : ArrayList<String>}
     * 3、Receive notification of friend's note modification
     * @param key TUIConstants.TUIContact.EVENT_FRIEND_INFO_CHANGED
     * @param subKey TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_REMARK_CHANGED
     * @param param {TUIConstants.TUIContact.FRIEND_ID : String, TUIConstants.TUIContact.FRIEND_REMARK : String}
     */
    @Override
    void onNotifyEvent(String key, String subKey, Map<String, Object> param);
}
