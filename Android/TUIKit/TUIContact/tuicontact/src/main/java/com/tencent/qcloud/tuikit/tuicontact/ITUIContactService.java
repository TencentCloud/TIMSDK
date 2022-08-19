package com.tencent.qcloud.tuikit.tuicontact;


import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;

import java.util.Map;

public interface ITUIContactService extends ITUIService, ITUINotification {
    @Override
    Object onCall(String method, Map<String, Object> param);

    /**
     * 接收好友备注修改通知
     * @param key TUIConstants.TUIContact.EVENT_FRIEND_INFO_CHANGED
     * @param subKey TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_REMARK_CHANGED
     * @param param {TUIConstants.TUIContact.FRIEND_ID : String, TUIConstants.TUIContact.FRIEND_REMARK : String}
     * 
     * 
     * Receive notification of friend's note modification
     * @param key TUIConstants.TUIContact.EVENT_FRIEND_INFO_CHANGED
     * @param subKey TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_REMARK_CHANGED
     * @param param {TUIConstants.TUIContact.FRIEND_ID : String, TUIConstants.TUIContact.FRIEND_REMARK : String}
     */
    @Override
    void onNotifyEvent(String key, String subKey, Map<String, Object> param);
}
