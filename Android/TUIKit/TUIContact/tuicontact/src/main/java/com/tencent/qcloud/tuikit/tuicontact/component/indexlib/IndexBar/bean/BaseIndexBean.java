package com.tencent.qcloud.tuikit.tuicontact.component.indexlib.IndexBar.bean;

import android.text.TextUtils;

import com.tencent.qcloud.tuikit.tuicontact.component.indexlib.suspension.ISuspensionInterface;

import java.io.Serializable;


public abstract class BaseIndexBean implements ISuspensionInterface, Serializable {

    private String baseIndexTag;//所属的分类（名字的汉语拼音首字母） // The category to which it belongs (the first letter of the Chinese pinyin of the name)

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
