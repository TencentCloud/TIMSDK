package com.tencent.qcloud.tuikit.tuichat.config;

import com.tencent.qcloud.tuikit.tuichat.interfaces.ChatEventListener;

/**
 * 本类用来从外部向 Chat 注册事件监听器，用来监听 Chat 的各个事件并作出相应的处理，比如监听点击头像事件，长按消息事件等
 *
 * This class is used to register event listeners for Chat from external sources, to listen for various events in Chat and respond accordingly, such as
 * listening for avatar click events, long-press message events, etc.
 */
public class ChatEventConfig {
    private ChatEventListener chatEventListener;

    public void setChatEventListener(ChatEventListener chatEventListener) {
        this.chatEventListener = chatEventListener;
    }

    public ChatEventListener getChatEventListener() {
        return chatEventListener;
    }
}
