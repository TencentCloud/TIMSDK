package com.tencent.qcloud.tuikit.tuichat.classicui.interfaces;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ILayout;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.noticelayout.NoticeLayout;
import com.tencent.qcloud.tuikit.tuichat.classicui.page.TUIBaseChatFragment;
import com.tencent.qcloud.tuikit.tuichat.classicui.setting.ChatLayoutSetting;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.ChatView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.InputView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.MessageRecyclerView;

/**
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

    InputView getInputLayout();

    MessageRecyclerView getMessageLayout();

    NoticeLayout getNoticeLayout();

    ChatInfo getChatInfo();

    void setChatInfo(ChatInfo chatInfo);

    void exitChat();

    void initDefault(TUIBaseChatFragment fragment);

    void loadMessages(int type);

    void sendMessage(TUIMessageBean msg, boolean retry);

    void customizeInputMoreLayout();
}
