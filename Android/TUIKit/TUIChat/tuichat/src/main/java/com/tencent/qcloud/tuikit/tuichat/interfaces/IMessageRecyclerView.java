package com.tencent.qcloud.tuikit.tuichat.interfaces;

public interface IMessageRecyclerView {
    int DATA_CHANGE_TYPE_REFRESH = 0;
    int DATA_CHANGE_TYPE_LOAD = 1;
    int DATA_CHANGE_TYPE_ADD_FRONT = 2;
    int DATA_CHANGE_TYPE_ADD_BACK = 3;
    int DATA_CHANGE_TYPE_UPDATE = 4;
    int DATA_CHANGE_TYPE_DELETE = 5;
    int DATA_CHANGE_TYPE_CLEAR = 6;
    
    // Refresh the message first and then locate the message location
    int DATA_CHANGE_LOCATE_TO_POSITION = 7;
    int DATA_CHANGE_NEW_MESSAGE = 8;
    
    // Scroll directly to message location
    int SCROLL_TO_POSITION = 9;
    
    // Refresh the message before scrolling to the message position
    int DATA_CHANGE_SCROLL_TO_POSITION = 10;
    
    // Refresh all messages before scrolling to the message position, without high light
    int DATA_CHANGE_SCROLL_TO_POSITION_WITHOUT_HIGH_LIGHT = 11;

    
    // Refresh the message before scrolling to the message position, without high light
    int DATA_CHANGE_SCROLL_TO_POSITION_AND_UPDATE = 12;

    boolean isDisplayJumpMessageLayout();

    void displayBackToNewMessage(boolean display, String messageId, int count);

    default void scrollToEnd() {}
}
