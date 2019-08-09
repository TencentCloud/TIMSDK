package com.tencent.qcloud.tim.uikit.modules.message;

import com.tencent.imsdk.ext.message.TIMMessageLocator;
import com.tencent.imsdk.ext.message.TIMMessageRevokedListener;

import java.util.ArrayList;
import java.util.List;


public class MessageRevokedManager implements TIMMessageRevokedListener {

    private static final MessageRevokedManager instance = new MessageRevokedManager();

    private MessageRevokedManager() {
    }

    public static MessageRevokedManager getInstance() {
        return instance;
    }

    private List<MessageRevokeHandler> mHandlers = new ArrayList<>();

    @Override
    public void onMessageRevoked(TIMMessageLocator locator) {
        for (int i = 0; i < mHandlers.size(); i++) {
            mHandlers.get(i).handleInvoke(locator);
        }
    }

    public void addHandler(MessageRevokeHandler handler) {
        if (!mHandlers.contains(handler)) {
            mHandlers.add(handler);
        }
    }

    public void removeHandler(MessageRevokeHandler handler) {
        mHandlers.remove(handler);
    }

    public interface MessageRevokeHandler {
        void handleInvoke(TIMMessageLocator locator);
    }
}
