package com.tencent.qcloud.tim.uikit.modules.chat.interfaces;

import com.tencent.qcloud.tim.uikit.base.ILayout;
import com.tencent.qcloud.tim.uikit.component.NoticeLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.base.ChatInfo;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.input.InputLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageLayout;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;

public interface IChatLayout extends ILayout {

    /**
     * 获取聊天窗口Input区域Layout
     *
     * @return
     */
    InputLayout getInputLayout();

    /**
     * 获取聊天窗口Message区域Layout
     *
     * @return
     */
    MessageLayout getMessageLayout();

    /**
     * 获取聊天窗口Message区域Layout
     *
     * @return
     */
    NoticeLayout getNoticeLayout();

    /**
     * 设置当前的会话ID，会话面板会依据该ID加载会话所需的相关信息，如消息记录，用户（群）信息等
     *
     * @param chatInfo
     */
    void setChatInfo(ChatInfo chatInfo);

    /**
     * 退出聊天，释放相关资源（一般在activity finish时调用）
     */
    void exitChat();

    /**
     * 初始化参数
     */
    void initDefault();

    /**
     * 加载聊天消息
     */
    void loadMessages();

    /**
     * 发送消息
     *
     * @param msg   消息
     * @param retry 是否重试
     */
    void sendMessage(MessageInfo msg, boolean retry);
}
