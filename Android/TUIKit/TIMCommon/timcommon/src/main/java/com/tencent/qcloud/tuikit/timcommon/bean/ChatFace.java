package com.tencent.qcloud.tuikit.timcommon.bean;

import java.io.Serializable;

public class ChatFace implements Serializable {
    private int width;
    private int height;
    protected String faceUrl;
    private FaceGroup<? extends ChatFace> faceGroup;
    private String faceKey;
    private String faceName;
    private boolean autoMirrored = false;

    public void setFaceKey(String faceKey) {
        this.faceKey = faceKey;
    }

    public String getFaceKey() {
        return faceKey;
    }

    public void setFaceName(String faceName) {
        this.faceName = faceName;
    }

    public String getFaceName() {
        return faceName;
    }

    public void setFaceGroup(FaceGroup<? extends ChatFace> faceGroup) {
        this.faceGroup = faceGroup;
    }

    public FaceGroup<? extends ChatFace> getFaceGroup() {
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

    public void setAutoMirrored(boolean autoMirrored) {
        this.autoMirrored = autoMirrored;
    }

    public boolean isAutoMirrored() {
        return autoMirrored;
    }
}
