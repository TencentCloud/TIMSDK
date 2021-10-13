package com.tencent.qcloud.tuikit.tuichat.bean;

import java.io.Serializable;

public class DraftInfo implements Serializable {
    private String draftText;
    private long draftTime;

    public String getDraftText() {
        return draftText;
    }

    public void setDraftText(String draftText) {
        this.draftText = draftText;
    }

    public long getDraftTime() {
        return draftTime;
    }

    public void setDraftTime(long draftTime) {
        this.draftTime = draftTime;
    }

    @Override
    public String toString() {
        return "DraftInfo{" +
                "draftText='" + draftText + '\'' +
                ", draftTime=" + draftTime +
                '}';
    }
}
