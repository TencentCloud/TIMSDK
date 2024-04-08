package com.tencent.qcloud.tuikit.tuichat.bean;

import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;

import java.io.Serializable;

public class MessageTyping implements Serializable {
    public String businessID = TUIChatConstants.BUSINESS_ID_CUSTOM_TYPING;
    public int typingStatus = 0; 
    public int version = TUIChatConstants.JSON_VERSION_UNKNOWN;

    
    public static final int TYPE_TYPING = 14;
    public static final String EDIT_START = "EIMAMSG_InputStatus_Ing";
    public static final String EDIT_END = "EIMAMSG_InputStatus_End";

    public int userAction = 0; 
    public String actionParam = ""; 

    public void setTypingStatus(boolean isTyping) {
        if (isTyping) {
            typingStatus = 1;

            // old version
            userAction = 14;
            actionParam = "EIMAMSG_InputStatus_Ing";
        } else {
            typingStatus = 0;

            // old version
            userAction = 0;
            actionParam = "EIMAMSG_InputStatus_End";
        }
    }
}
