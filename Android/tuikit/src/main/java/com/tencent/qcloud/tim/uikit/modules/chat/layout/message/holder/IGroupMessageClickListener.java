package com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder;

import com.tencent.qcloud.tim.uikit.modules.message.LiveMessageInfo;

public interface IGroupMessageClickListener {
    /**
     * 设置点击群消息处理回调
     * @param info
     * @param groupId
     * @return true: 上层处理该消息，不会走默认创建 false: 将会走默认的创建逻辑
     */
    boolean handleLiveMessage(LiveMessageInfo info, String groupId);
}
