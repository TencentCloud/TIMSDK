package com.tencent.qcloud.tuikit.timcommon.bean;

import android.text.TextUtils;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.Map;

public class FaceGroup<T extends ChatFace> {
    private int groupID;
    private String groupName;
    private String desc;
    private Object faceGroupIconUrl;
    private int pageRowCount;
    private int pageColumnCount;
    private boolean isEmoji = false;
    private final Map<String, T> faces = new LinkedHashMap<>();

    public int getGroupID() {
        return groupID;
    }

    public void setGroupID(int groupID) {
        this.groupID = groupID;
    }

    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }

    public String getGroupName() {
        return groupName;
    }

    public boolean isEmojiGroup() {
        return isEmoji;
    }

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }

    public void setFaceGroupIconUrl(Object faceGroupIconUrl) {
        this.faceGroupIconUrl = faceGroupIconUrl;
    }

    public Object getFaceGroupIconUrl() {
        return faceGroupIconUrl;
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

    public ArrayList<T> getFaces() {
        return new ArrayList<>(faces.values());
    }

    public void addFace(String faceKey, T face) {
        if (face instanceof Emoji) {
            isEmoji = true;
        }
        face.setFaceGroup(this);
        faces.put(faceKey, face);
    }

    public T getFace(String faceKey) {
        if (TextUtils.isEmpty(faceKey)) {
            return null;
        }
        T face = faces.get(faceKey);
        if (face == null) {
            int index = faceKey.lastIndexOf("@2x");
            if (index == -1) {
                return null;
            }
            String oldFaceKey = faceKey.substring(0, index);
            face = faces.get(oldFaceKey);
        }
        return face;
    }
}
