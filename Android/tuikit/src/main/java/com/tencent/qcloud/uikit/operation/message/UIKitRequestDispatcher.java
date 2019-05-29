package com.tencent.qcloud.uikit.operation.message;

import java.util.HashMap;


public class UIKitRequestDispatcher {
    public static final String MODEL_SESSION = "model_session";
    public static final String SESSION_ACTION_GET_TOP = "get_top";
    public static final String SESSION_ACTION_SET_TOP = "set_top";
    public static final String SESSION_DELETE = "delete";
    public static final String SESSION_REFRESH = "refresh";
    public static final String SESSION_ACTION_START_CHAT = "start_chat";


    private static final UIKitRequestDispatcher instance = new UIKitRequestDispatcher();

    private UIKitRequestDispatcher() {
    }

    public static UIKitRequestDispatcher getInstance() {
        return instance;
    }

    private HashMap<String, UIKitRequestHandler> valueHandlers = new HashMap<>();


    public Object dispatchRequest(UIKitRequest msg) {
        UIKitRequestHandler handler = valueHandlers.get(msg.getModel());
        if (handler != null)
            return handler.handleRequest(msg);
        return null;
    }

    public void registerHandler(String model, UIKitRequestHandler handler) {
        valueHandlers.put(model, handler);
    }

    public void unRegisterHandler(String model) {
        valueHandlers.remove(model);
    }


}
