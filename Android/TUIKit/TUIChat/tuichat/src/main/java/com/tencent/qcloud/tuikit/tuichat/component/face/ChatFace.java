package com.tencent.qcloud.tuikit.tuichat.component.face;

import java.io.Serializable;

public class ChatFace implements Serializable {
    private int width;
    private int height;
    protected String faceUrl;
    private FaceGroup faceGroup;
    private String faceKey;

    public void setFaceKey(String faceKey) {
        this.faceKey = faceKey;
    }

    public String getFaceKey() {
        return faceKey;
    }

    public void setFaceGroup(FaceGroup faceGroup) {
        this.faceGroup = faceGroup;
    }

    public FaceGroup getFaceGroup() {
        return faceGroup;
    }

    public void setWidth(int width) {
        this.width = width;
    }

    public void setHeight(int height) {
        this.height = height;
    }

    public void setFaceUrl(String faceUrl) {
        this.faceUrl = faceUrl;
    }

    public String getFaceUrl() {
        return faceUrl;
    }

    public int getHeight() {
        return height;
    }

    public int getWidth() {
        return width;
    }
}
