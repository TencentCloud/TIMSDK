package com.tencent.liteav.trtccalling.model.util;

import android.os.Handler;
import android.os.Looper;
import android.os.Message;

import java.util.HashSet;
import java.util.Set;

public class EventHandler extends Handler {

    /**
     * 主动挂断电话
     */
    public static final int EVENT_TYPE_ACTIVE_HANGUP = 1;

    private static final EventHandler HANDLER = new EventHandler();

    private final Set<Handler> handlers = new HashSet<>();

    public static final EventHandler sharedInstance() {
        return HANDLER;
    }

    private EventHandler() {
        super(Looper.getMainLooper());
    }

    public void addHandler(Handler handler) {
        if (null != handler) {
            handlers.add(handler);
        }
    }

    @Override
    public void handleMessage(Message msg) {
        for (Handler handler : handlers) {
            Message message = new Message();
            message.copyFrom(msg);
            handler.sendMessage(message);
        }
    }
}
