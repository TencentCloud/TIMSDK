package com.tencent.qcloud.uikit.operation;

import com.tencent.imsdk.ext.message.TIMMessageLocator;
import com.tencent.imsdk.ext.message.TIMMessageRevokedListener;
import com.tencent.qcloud.uikit.TUIKit;

import java.util.ArrayList;
import java.util.List;


public class UIKitMessageRevokedManager implements TIMMessageRevokedListener {

    private static final UIKitMessageRevokedManager instance = new UIKitMessageRevokedManager();

    private UIKitMessageRevokedManager() {
    }

    public static UIKitMessageRevokedManager getInstance() {
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
        mHandlers.add(handler);
    }

    public void removeHandler(MessageRevokeHandler handler) {
        mHandlers.remove(handler);
    }

    public interface MessageRevokeHandler {
        public void handleInvoke(TIMMessageLocator locator);

    }
}
