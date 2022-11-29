package com.tencent.qcloud.tuikit.tuichat.component.face;

import android.text.TextUtils;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.Map;

public class FaceGroup {
    private int groupID;
    private String groupName;
    private String desc;
    private String faceGroupIconUrl;
    private int pageRowCount;
    private int pageColumnCount;
    private final Map<String, ChatFace> faces = new LinkedHashMap<>();

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

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }

    public void setFaceGroupIconUrl(String faceGroupIconUrl) {
        this.faceGroupIconUrl = faceGroupIconUrl;
    }

    public String getFaceGroupIconUrl() {
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

    public ArrayList<ChatFace> getFaces() {
        return new ArrayList<>(faces.values());
    }

    public void addFace(String faceKey, ChatFace face) {
        face.setFaceGroup(this);
        faces.put(faceKey, face);
    }

    public ChatFace getFace(String faceKey) {
        if (TextUtils.isEmpty(faceKey)) {
            return null;
        }
        ChatFace face = faces.get(faceKey);
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
