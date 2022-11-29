package com.tencent.qcloud.tuikit.tuichat.interfaces;

public interface IMessageRecyclerView {
    int DATA_CHANGE_TYPE_REFRESH = 0;
    int DATA_CHANGE_TYPE_LOAD = 1;
    int DATA_CHANGE_TYPE_ADD_FRONT = 2;
    int DATA_CHANGE_TYPE_ADD_BACK = 3;
    int DATA_CHANGE_TYPE_UPDATE = 4;
    int DATA_CHANGE_TYPE_DELETE = 5;
    int DATA_CHANGE_TYPE_CLEAR = 6;
    // 先刷新消息再定位到消息位置
    // Refresh the message first and then locate the message location
    int DATA_CHANGE_LOCATE_TO_POSITION = 7;
    int DATA_CHANGE_NEW_MESSAGE = 8;
    // 直接滚动到消息位置
    // Scroll directly to message location
    int SCROLL_TO_POSITION = 9;
    // 先刷新消息再滚动到消息位置
    // Refresh the message before scrolling to the message position
    int DATA_CHANGE_SCROLL_TO_POSITION = 10;

    boolean isDisplayJumpMessageLayout();
    void displayBackToNewMessage(boolean display, String messageId, int count);

}
