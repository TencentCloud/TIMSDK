package com.tencent.qcloud.tuikit.tuichat.bean;


import android.view.View;

public class InputMoreActionUnit {

    private ChatInfo chatInfo;

    private int iconResId;

    private int titleId;

    private int actionId;
    
    private View unitView;

    // 0, not need onActivityResult; 1, need onActivityResult
    private int actionType = 0;

    // 数字越小优先级越高
    // The lower the number, the higher the priority
    private int priority = 0;

    private OnActionClickListener onClickListener = new OnActionClickListener();

    public int getPriority() {
        return priority;
    }

    public void setPriority(int priority) {
        this.priority = priority;
    }

    public int getChatType() {
        if (chatInfo != null) {
            return chatInfo.getType();
        } else {
            return 0;
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

    public void setUnitView(View unitView) {
        this.unitView = unitView;
    }

    public View getUnitView() {
        return unitView;
    }

    public boolean isEnable(int chatType) {
        return true;
    }
    
    public void onAction(String chatInfoId, int chatType) {

    }

    public int getActionType() {
        return actionType;
    }

    public void setActionType(int actionType) {
        this.actionType = actionType;
    }

    public class OnActionClickListener {
        public void onClick() {
            onAction(getChatId(), getChatType());
        }
    }
}
