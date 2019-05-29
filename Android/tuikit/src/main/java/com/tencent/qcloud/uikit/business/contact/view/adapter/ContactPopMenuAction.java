package com.tencent.qcloud.uikit.business.contact.view.adapter;

import android.graphics.Bitmap;
import android.widget.AdapterView;


public class ContactPopMenuAction {

    private String actionName;
    private Bitmap icon;
    private AdapterView.OnItemClickListener onItemClickListener;

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

    public AdapterView.OnItemClickListener getOnItemClickListener() {
        return onItemClickListener;
    }

    public void setOnItemClickListener(AdapterView.OnItemClickListener onItemClickListener) {
        this.onItemClickListener = onItemClickListener;
    }

}
