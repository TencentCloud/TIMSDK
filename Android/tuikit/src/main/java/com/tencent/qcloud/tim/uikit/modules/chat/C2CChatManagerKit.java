package com.tencent.qcloud.tim.uikit.modules.chat;


import com.tencent.qcloud.tim.uikit.modules.chat.base.ChatInfo;
import com.tencent.qcloud.tim.uikit.modules.chat.base.ChatManagerKit;

public class C2CChatManagerKit extends ChatManagerKit {

    private static final String TAG = C2CChatManagerKit.class.getSimpleName();

    private ChatInfo mCurrentChatInfo;

    private static C2CChatManagerKit mKit;

    private C2CChatManagerKit() {
        super.init();
    }

    public static C2CChatManagerKit getInstance() {
        if (mKit == null) {
            mKit = new C2CChatManagerKit();
        }
        return mKit;
    }

    @Override
    public void setCurrentChatInfo(ChatInfo info) {
        super.setCurrentChatInfo(info);
        mCurrentChatInfo = info;
    }

    @Override
    public void destroyChat() {
        super.destroyChat();
        mCurrentChatInfo = null;
        mIsMore = true;
    }

    @Override
    public ChatInfo getCurrentChatInfo() {
        return mCurrentChatInfo;
    }

    @Override
    protected boolean isGroup() {
        return false;
    }
}
