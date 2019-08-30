package com.tencent.qcloud.tim.uikit.modules.chat.interfaces;

import com.tencent.qcloud.tim.uikit.base.ILayout;
import com.tencent.qcloud.tim.uikit.component.NoticeLayout;
import com.tencent.qcloud.tim.uikit.component.TitleBarLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.ChatLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.base.ChatInfo;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.input.InputLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageLayout;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;

/**
 * 聊天窗口 {@link ChatLayout} 提供了消息的展示与发送等功能，界面布局从上到下分为四个部分: <br>
 * <pre>    标题区 {@link TitleBarLayout}，
 *  提醒区 {@link NoticeLayout}，
 *  消息区 {@link MessageLayout}，
 *  输入区 {@link InputLayout}，</pre>
 * 每个区域提供了多样的方法以供定制使用。
 */
public interface IChatLayout extends ILayout {

    /**
     * 获取聊天窗口 Input 区域 Layout
     *
     * @return
     */
    InputLayout getInputLayout();

    /**
     * 获取聊天窗口 Message 区域 Layout
     *
     * @return
     */
    MessageLayout getMessageLayout();

    /**
     * 获取聊天窗口 Notice 区域 Layout
     *
     * @return
     */
    NoticeLayout getNoticeLayout();

    /**
     * 设置当前的会话 ID，会话面板会依据该 ID 加载会话所需的相关信息，如消息记录，用户（群）信息等
     *
     * @param chatInfo
     */
    void setChatInfo(ChatInfo chatInfo);

    /**
     * 退出聊天，释放相关资源（一般在 activity finish 时调用）
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
