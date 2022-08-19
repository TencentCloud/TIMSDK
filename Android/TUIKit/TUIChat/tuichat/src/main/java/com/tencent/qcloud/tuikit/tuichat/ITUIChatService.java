package com.tencent.qcloud.tuikit.tuichat;

import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;

import java.util.Map;

public interface ITUIChatService extends ITUIService, ITUINotification {
    /**
     * 1、发送消息
     *   Send Message
     * 
     * @param method TUIConstants.TUIChat.METHOD_SEND_MESSAGE
     * @param param {TUIConstants.TUIChat.CHAT_ID : String, TUIConstants.TUIChat.CHAT_TYPE : Integer,
     *              TUIConstants.TUIChat.MESSAGE_CONTENT : String, TUIConstants.TUIChat.MESSAGE_DESCRIPTION : String,
     *              TUIConstants.TUIChat.MESSAGE_EXTENSION : String}
     * 2、退出聊天
     *   Exit Chat
     * 
     * @param method TUIConstants.TUIChat.METHOD_EXIT_CHAT
     * @param param {TUIConstants.TUIChat.CHAT_ID : String, TUIConstants.TUIChat.IS_GROUP_CHAT : Boolean}
     *
     * 3、获取消息摘要
     *   Get message digest
     * 
     * @param method TUIConstants.TUIChat.METHOD_GET_DISPLAY_STRING
     * @param param {TUIConstants.TUIChat.V2TIMMESSAGE : V2TIMMessage}
     */
    @Override
    Object onCall(String method, Map<String, Object> param);

    /**
     * 1、接收退群通知
     *   Receive exit group notifications
     * 
     * @param key TUIConstants.TUIGroup.EVENT_GROUP
     * @param subKey TUIConstants.TUIGroup.EVENT_SUB_KEY_EXIT_GROUP,
     *               TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_DISMISS,
     *               TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_RECYCLE
     * @param param {TUIConstants.TUIGroup.GROUP_ID : String}
     * 2、接收群名称修改通知
     *   Receive group name change notification
     * 
     * @param key TUIConstants.TUIGroup.EVENT_GROUP
     * @param subKey TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_INFO_CHANGED
     * @param param {TUIConstants.TUIGroup.GROUP_ID : String, TUIConstants.TUIGroup.GROUP_NAME : String}
     * 3、接收群成员退群通知
     *   Receive group member withdrawal notification
     * 
     * @param key TUIConstants.TUIGroup.EVENT_GROUP
     * @param subKey TUIConstants.TUIGroup.EVENT_SUB_KEY_MEMBER_KICKED_GROUP
     * @param param {TUIConstants.TUIGroup.GROUP_ID : String, TUIConstants.TUIGroup.GROUP_MEMBER_ID_LIST : ArrayList<String>}
     * 4、接收好友备注修改通知
     *   Receive notifications of changes to friends' notes.
     * 
     * @param key TUIConstants.TUIContact.EVENT_FRIEND_INFO_CHANGED
     * @param subKey TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_REMARK_CHANGED
     * @param param {TUIConstants.TUIContact.FRIEND_ID : String, TUIConstants.TUIContact.FRIEND_REMARK : String}
     */
    @Override
    void onNotifyEvent(String key, String subKey, Map<String, Object> param);
}
