package com.tencent.qcloud.tuikit.tuichat.classicui.interfaces;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ILayout;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.noticelayout.NoticeLayout;
import com.tencent.qcloud.tuikit.tuichat.classicui.page.TUIBaseChatFragment;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.ChatView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.InputView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.MessageRecyclerView;

/**
 * 聊天窗口 {@link ChatView} 提供了消息的展示与发送等功能，界面布局从上到下分为四个部分: <br>
 * <pre>    标题区 {@link TitleBarLayout}，
 *  提醒区 {@link NoticeLayout}，
 *  消息区 {@link MessageRecyclerView}，
 *  输入区 {@link InputView}，</pre>
 * 每个区域提供了多样的方法以供定制使用。
 *
 *
 * The chat window {@link ChatView} provides functions such as displaying and sending messages.
 * The interface layout is divided into four parts from top to bottom:
 *  TitleBarLayout {@link TitleBarLayout}，
 *  NoticeLayout {@link NoticeLayout}，
 *  MessageRecyclerView {@link MessageRecyclerView}，
 *  InputView {@link InputView},
 *  Each area offers a variety of methods for customization.
 */
public interface IChatLayout extends ILayout {
    /**
     * 获取聊天窗口 Input 区域 Layout
     *
     * @return
     */
    InputView getInputLayout();

    /**
     * 获取聊天窗口 Message 区域 Layout
     *
     * @return
     */
    MessageRecyclerView getMessageLayout();

    /**
     * 获取聊天窗口 Notice 区域 Layout
     *
     * @return
     */
    NoticeLayout getNoticeLayout();

    /**
     * 获取当前的会话信息
     */
    ChatInfo getChatInfo();

    /**
     * 设置当前的会话信息
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
    void initDefault(TUIBaseChatFragment fragment);

    /**
     * 加载聊天消息
     */
    void loadMessages(int type);

    /**
     * 发送消息
     *
     * @param msg   消息
     * @param retry 是否重试
     */
    void sendMessage(TUIMessageBean msg, boolean retry);
}
