package com.tencent.qcloud.tuikit.tuicontact.component.indexlib.indexbar.bean;

import android.text.TextUtils;

import com.tencent.qcloud.tuikit.tuicontact.component.indexlib.suspension.ISuspensionInterface;

import java.io.Serializable;

public abstract class BaseIndexBean implements ISuspensionInterface, Serializable {
    private String baseIndexTag; 

    public String getBaseIndexTag() {
        return baseIndexTag;
    }

    public BaseIndexBean setBaseIndexTag(String baseIndexTag) {
        this.baseIndexTag = baseIndexTag;
        return this;
    }

    @Override
    public String getSuspensionTag() {
        if (TextUtils.isEmpty(baseIndexTag)) {
            return "";
        }
        return baseIndexTag;
    }

    @Override
    public boolean isShowSuspension() {
        return true;
    }
}
