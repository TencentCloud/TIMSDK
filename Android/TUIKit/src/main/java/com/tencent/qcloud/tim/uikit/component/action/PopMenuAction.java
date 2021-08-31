package com.tencent.qcloud.tim.uikit.component.action;

import android.graphics.Bitmap;

public class PopMenuAction {

    private String actionName;
    private Bitmap icon;
    private int iconResId;
    private PopActionClickListener actionClickListener;

    public String getActionName() {
        return actionName;
    }

    public void setActionName(String actionName) {
        this.actionName = actionName;
    }

    public Bitmap getIcon() {
        return icon;
    }

    public void setIcon(Bitmap mIcon) {
        this.icon = mIcon;
    }


    public int getIconResId() {
        return iconResId;
    }

    public void setIconResId(int iconResId) {
        this.iconResId = iconResId;
    }

    public PopActionClickListener getActionClickListener() {
        return actionClickListener;
    }

    public void setActionClickListener(PopActionClickListener actionClickListener) {
        this.actionClickListener = actionClickListener;
    }
}
