package com.tencent.qcloud.tuikit.tuicontact.component.indexlib.IndexBar.bean;


public abstract class BaseIndexPinyinBean extends BaseIndexBean {

    private String baseIndexPinyin;

    public String getBaseIndexPinyin() {
        return baseIndexPinyin;
    }

    public BaseIndexPinyinBean setBaseIndexPinyin(String baseIndexPinyin) {
        this.baseIndexPinyin = baseIndexPinyin;
        return this;
    }

    public boolean isNeedToPinyin() {
        return true;
    }

    public abstract String getTarget();


}
