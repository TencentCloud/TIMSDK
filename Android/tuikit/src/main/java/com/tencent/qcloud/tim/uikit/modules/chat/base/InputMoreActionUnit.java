package com.tencent.qcloud.tim.uikit.modules.chat.base;

import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.qcloud.tim.uikit.base.IBaseAction;


public class InputMoreActionUnit implements IBaseAction {

    private ChatInfo chatInfo;

    private int iconResId;

    private int titleId;

    private int actionId;

    private OnActionClickListener onClickListener = new OnActionClickListener();

    public int getChatType() {
        if (chatInfo != null) {
            return chatInfo.getType();
        } else {
            return V2TIMConversation.CONVERSATION_TYPE_INVALID;
        }
    }

    public String getChatId() {
        if (chatInfo != null) {
            return chatInfo.getId();
        } else {
            return null;
        }
    }

    public void setChatInfo(ChatInfo chatInfo) {
        this.chatInfo = chatInfo;
    }

    public int getIconResId() {
        return iconResId;
    }

    public void setIconResId(int iconResId) {
        this.iconResId = iconResId;
    }

    public int getTitleId() {
        return titleId;
    }

    public void setTitleId(int titleId) {
        this.titleId = titleId;
    }

    public int getActionId() {
        return actionId;
    }

    public void setActionId(int actionId) {
        this.actionId = actionId;
    }

    public OnActionClickListener getOnClickListener() {
        return onClickListener;
    }

    public void setOnClickListener(OnActionClickListener onClickListener) {
        this.onClickListener = onClickListener;
    }

    // 注册者决定是否显示该 Action
    public boolean isEnable(int chatType) {
        return true;
    }

    // 点击更多图标时具体执行方法
    public void onAction(String chatInfoId, int chatType) {

    }

    public class OnActionClickListener {
        public void onClick() {
            onAction(getChatId(), getChatType());
        }
    }
}
