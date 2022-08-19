package com.tencent.qcloud.tuikit.tuicommunity.bean;

import com.tencent.qcloud.tuikit.tuicommunity.interfaces.ITopicBean;

import java.io.Serializable;

public class TopicFoldBean implements ITopicBean, Serializable {
    private String foldName;

    public String getFoldName() {
        return foldName;
    }

    public void setFoldName(String foldName) {
        this.foldName = foldName;
    }

    @Override
    public int compareTo(ITopicBean o) {
        if (o instanceof TopicBean) {
            return 1;
        }
        return 0;
    }
}
