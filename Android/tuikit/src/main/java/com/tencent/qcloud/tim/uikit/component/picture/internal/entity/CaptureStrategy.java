package com.tencent.qcloud.tim.uikit.component.picture.internal.entity;

public class CaptureStrategy {

    public final boolean isPublic;
    public final String authority;

    public CaptureStrategy(boolean isPublic, String authority) {
        this.isPublic = isPublic;
        this.authority = authority;
    }
}
