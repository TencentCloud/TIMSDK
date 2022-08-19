package com.tencent.qcloud.tuikit.tuichat.component.face;


import java.util.ArrayList;

public class CustomFaceGroup {

    private int faceGroupId;
    private String faceIconPath;
    private String faceIconName;
    private int pageRowCount;
    private int pageColumnCount;
    private ArrayList<CustomFace> array = new ArrayList<>();

    /**
     * 增加一个表情
     * 
     * add an emoji
     *
     * @param face
     */
    public void addCustomFace(CustomFace face) {
        array.add(face);
    }

    /**
     * 获取表情包
     *
     * Get emoji
     * 
     * @return
     */
    public ArrayList<CustomFace> getCustomFaceList() {
        return array;
    }

    /**
     * 获取表情包所在的组ID
     * 
     * Get the group ID of the emoji
     *
     * @return
     */
    public int getFaceGroupId() {
        return faceGroupId;
    }

    /**
     * 设置表情包所在的组ID
     * 
     * Set the group ID where the emoji is located
     *
     * @param faceGroupId
     */
    public void setFaceGroupId(int faceGroupId) {
        this.faceGroupId = faceGroupId;
    }

    /**
     * 获取表情包的封面
     * 
     * Get the cover of the emoji
     *
     * @return
     */
    public String getFaceIconPath() {
        return faceIconPath;
    }

    /**
     * 设置表情包的封面
     * 
     * Set the cover of the emoji
     *
     * @param faceIconPath
     */
    public void setFaceIconPath(String faceIconPath) {
        this.faceIconPath = faceIconPath;
    }

    /**
     * 获取表情包每行显示数量
     * 
     * Get the number of emoticons displayed in each line
     *
     * @return
     */
    public int getPageRowCount() {
        return pageRowCount;
    }

    /**
     * 设置表情包每行的显示数量
     * 
     * Set the number of emoticons displayed in each line
     *
     * @param pageRowCount
     */
    public void setPageRowCount(int pageRowCount) {
        this.pageRowCount = pageRowCount;
    }

    /**
     * 获取表情包的列数量
     * 
     * Get the number of columns of the emoji
     *
     * @return
     */
    public int getPageColumnCount() {
        return pageColumnCount;
    }

    /**
     * 设置表情包的列数量
     * 
     * Set the number of columns in the emoji
     *
     * @param pageColumnCount
     */
    public void setPageColumnCount(int pageColumnCount) {
        this.pageColumnCount = pageColumnCount;
    }

    /**
     * 获取表情包的名称
     * 
     * Get the name of the emoji
     *
     * @return
     */
    public String getFaceIconName() {
        return faceIconName;
    }

    /**
     * 设置表情包的名称
     * 
     * Set the name of the emoji
     *
     * @param faceIconName
     */
    public void setFaceIconName(String faceIconName) {
        this.faceIconName = faceIconName;
    }
}
