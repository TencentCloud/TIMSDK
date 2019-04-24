package com.tencent.qcloud.uikit.business.chat.view.widget;


import java.util.ArrayList;


public class CustomFaceGroupConfigs {

    private int faceGroupId;
    private String faceIconPath;
    private String faceIconName;
    private int pageRowCount;
    private int pageColumnCount;
    private ArrayList<FaceConfig> array = new ArrayList<>();

    public void addFaceConfig(FaceConfig config) {
        array.add(config);
    }

    public ArrayList<FaceConfig> getFaceConfigs() {
        return array;
    }

    public int getFaceGroupId() {
        return faceGroupId;
    }

    public void setFaceGroupId(int faceGroupId) {
        this.faceGroupId = faceGroupId;
    }

    public String getFaceIconPath() {
        return faceIconPath;
    }

    public int getPageRowCount() {
        return pageRowCount;
    }

    public void setPageRowCount(int pageRowCount) {
        this.pageRowCount = pageRowCount;
    }

    public int getPageColumnCount() {
        return pageColumnCount;
    }

    public void setPageColumnCount(int pageColumnCount) {
        this.pageColumnCount = pageColumnCount;
    }

    public void setFaceIconPath(String faceIconPath) {
        this.faceIconPath = faceIconPath;
    }

    public String getFaceIconName() {
        return faceIconName;
    }

    public void setFaceIconName(String faceIconName) {
        this.faceIconName = faceIconName;
    }
}
