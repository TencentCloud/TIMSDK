package com.tencent.qcloud.tuikit.tuichat.minimalistui.interfaces;

import com.tencent.qcloud.tuicore.component.interfaces.ILayout;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.input.InputView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.MessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.component.noticelayout.NoticeLayout;

/**
 * 聊天窗口 {@link com.tencent.qcloud.tuikit.tuichat.classicui.widget.ChatView} 提供了消息的展示与发送等功能，界面布局从上到下分为四个部分: <br>
 * <pre>    标题区 {@link com.tencent.qcloud.tuicore.component.TitleBarLayout}，
 *  提醒区 {@link com.tencent.qcloud.tuikit.tuichat.minimalistui.component.noticelayout.NoticeLayout}，
 *  消息区 {@link com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.MessageRecyclerView}，
 *  输入区 {@link com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.InputView}，</pre>
 * 每个区域提供了多样的方法以供定制使用。
 * 
 * 
 * The chat window {@link com.tencent.qcloud.tuikit.tuichat.classicui.widget.ChatView} provides functions such as displaying and sending messages.
 * The interface layout is divided into four parts from top to bottom:
 *  TitleBarLayout {@link com.tencent.qcloud.tuicore.component.TitleBarLayout}，
 *  NoticeLayout {@link com.tencent.qcloud.tuikit.tuichat.minimalistui.component.noticelayout.NoticeLayout}，
 *  MessageRecyclerView {@link com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.MessageRecyclerView}，
 *  InputView {@link com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.InputView},
 *  Each area offers a variety of methods for customization.
 */
public interface IChatLayout  {

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
    void initDefault();

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
