package com.tencent.qcloud.tuikit.tuichat.config;

import com.tencent.qcloud.tuikit.tuichat.interfaces.ChatEventListener;

/**
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
