package com.tencent.qcloud.tuikit.tuichat.interfaces;

import android.view.View;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;


// Chat event listener
public interface ChatEventListener {
    /**
     *
     * This callback is triggered when a user avatar in the chat list interface is clicked. Returning true indicates that this event has been intercepted, and
     * Chat will not process it further. Returning false indicates that this event is not intercepted, and Chat will continue to process it.
     */
    default boolean onUserIconClicked(View view, TUIMessageBean messageBean) {
        return false;
    }

    /**
     *
     * This callback is triggered when a user avatar in the chat list interface is long-pressed. Returning true indicates that this event has been intercepted,
     * and Chat will not process it further. Returning false indicates that this event is not intercepted, and Chat will continue to process it.
     */
    default boolean onUserIconLongClicked(View view, TUIMessageBean messageBean) {
        return false;
    }

    /**
     *
     * This callback is triggered when a message in the chat list interface is clicked. Returning true indicates that this event has been intercepted, and Chat
     * will not process it further. Returning false indicates that this event is not intercepted, and Chat will continue to process it.
     */
    default boolean onMessageClicked(View view, TUIMessageBean messageBean) {
        return false;
    }

    /**
     *
     * This callback is triggered when a message in the chat list interface is long-pressed. Returning true indicates that this event has been intercepted, and
     * Chat will not process it further. Returning false indicates that this event is not intercepted, and Chat will continue to process it.
     */
    default boolean onMessageLongClicked(View view, TUIMessageBean messageBean) {
        return false;
    }
}
