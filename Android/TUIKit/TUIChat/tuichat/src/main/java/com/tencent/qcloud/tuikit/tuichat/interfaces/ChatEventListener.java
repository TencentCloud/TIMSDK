package com.tencent.qcloud.tuikit.tuichat.interfaces;

import android.view.View;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;

// Chat 事件监听器
// Chat event listener
public interface ChatEventListener {
    /**
     * 聊天列表界面用户头像被点击时触发此回调，返回 true 表示此事件已经被拦截，Chat 内部后续不再处理， 返回 false 表示此事件不被拦截， Chat 内部会继续处理
     *
     * This callback is triggered when a user avatar in the chat list interface is clicked. Returning true indicates that this event has been intercepted, and
     * Chat will not process it further. Returning false indicates that this event is not intercepted, and Chat will continue to process it.
     */
    default boolean onUserIconClicked(View view, TUIMessageBean messageBean) {
        return false;
    }

    /**
     * 聊天列表界面用户头像被长按时触发此回调，返回 true 表示此事件已经被拦截，Chat 内部后续不再处理， 返回 false 表示此事件不被拦截， Chat 内部会继续处理
     *
     * This callback is triggered when a user avatar in the chat list interface is long-pressed. Returning true indicates that this event has been intercepted,
     * and Chat will not process it further. Returning false indicates that this event is not intercepted, and Chat will continue to process it.
     */
    default boolean onUserIconLongClicked(View view, TUIMessageBean messageBean) {
        return false;
    }

    /**
     * 聊天列表界面消息被点击时触发此回调，返回 true 表示此事件已经被拦截，Chat 内部后续不再处理， 返回 false 表示此事件不被拦截， Chat 内部会继续处理
     *
     * This callback is triggered when a message in the chat list interface is clicked. Returning true indicates that this event has been intercepted, and Chat
     * will not process it further. Returning false indicates that this event is not intercepted, and Chat will continue to process it.
     */
    default boolean onMessageClicked(View view, TUIMessageBean messageBean) {
        return false;
    }

    /**
     * 聊天列表界面消息被长按时触发此回调，返回 true 表示此事件已经被拦截，Chat 内部后续不再处理， 返回 false 表示此事件不被拦截， Chat 内部会继续处理
     *
     * This callback is triggered when a message in the chat list interface is long-pressed. Returning true indicates that this event has been intercepted, and
     * Chat will not process it further. Returning false indicates that this event is not intercepted, and Chat will continue to process it.
     */
    default boolean onMessageLongClicked(View view, TUIMessageBean messageBean) {
        return false;
    }
}
