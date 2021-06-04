package com.tencent.qcloud.tim.uikit.modules.message;

import com.tencent.imsdk.v2.V2TIMAdvancedMsgListener;

import java.util.ArrayList;
import java.util.List;


public class MessageRevokedManager extends V2TIMAdvancedMsgListener {

    private static final MessageRevokedManager instance = new MessageRevokedManager();
    private List<MessageRevokeHandler> mHandlers = new ArrayList<>();

    private MessageRevokedManager() {
    }

    public static MessageRevokedManager getInstance() {
        return instance;
    }

    @Override
    public void onRecvMessageRevoked(String msgID) {
        for (int i = 0; i < mHandlers.size(); i++) {
            mHandlers.get(i).handleRevoke(msgID);
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
        void handleRevoke(String msgID);
    }
}
