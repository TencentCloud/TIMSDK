package com.tencent.qcloud.tim.uikit.component.face;

import android.graphics.Bitmap;

import java.util.ArrayList;

public class FaceGroup {
    private int groupId;
    private String desc;
    private Bitmap groupIcon;
    private int pageRowCount;
    private int pageColumnCount;
    private ArrayList<Emoji> faces;


    public int getGroupId() {
        return groupId;
    }

    public void setGroupId(int groupId) {
        this.groupId = groupId;
    }

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }

    public Bitmap getGroupIcon() {
        return groupIcon;
    }

    public void setGroupIcon(Bitmap groupIcon) {
        this.groupIcon = groupIcon;
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

    public ArrayList<Emoji> getFaces() {
        return faces;
    }

    public void setFaces(ArrayList<Emoji> faces) {
        this.faces = faces;
    }
}
