package com.tencent.qcloud.uikit.business.contact.view.widget.IndexBar.bean;
import com.tencent.qcloud.uikit.business.contact.view.widget.suspension.ISuspensionInterface;

/**
 * 介绍：索引类的标志位的实体基类
 */

public abstract class BaseIndexBean implements ISuspensionInterface {

    private String baseIndexTag;//所属的分类（城市的汉语拼音首字母）

    public String getBaseIndexTag() {
        return baseIndexTag;
    }

    public BaseIndexBean setBaseIndexTag(String baseIndexTag) {
        this.baseIndexTag = baseIndexTag;
        return this;
    }

    @Override
    public String getSuspensionTag() {
        return baseIndexTag;
    }

    @Override
    public boolean isShowSuspension() {
        return true;
    }
}
