package com.tencent.qcloud.tim.uikit.component.face;


import java.util.ArrayList;

/**
 * 一个表情包
 */
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
     * @param face
     */
    public void addCustomFace(CustomFace face) {
        array.add(face);
    }

    /**
     * 获取表情包
     *
     * @return
     */
    public ArrayList<CustomFace> getCustomFaceList() {
        return array;
    }

    /**
     * 获取表情包所在的组ID
     *
     * @return
     */
    public int getFaceGroupId() {
        return faceGroupId;
    }

    /**
     * 设置表情包所在的组ID
     *
     * @param faceGroupId
     */
    public void setFaceGroupId(int faceGroupId) {
        this.faceGroupId = faceGroupId;
    }

    /**
     * 获取表情包的封面
     *
     * @return
     */
    public String getFaceIconPath() {
        return faceIconPath;
    }

    /**
     * 获取表情包每行显示数量
     *
     * @return
     */
    public int getPageRowCount() {
        return pageRowCount;
    }

    /**
     * 设置表情包每行的显示数量
     *
     * @param pageRowCount
     */
    public void setPageRowCount(int pageRowCount) {
        this.pageRowCount = pageRowCount;
    }

    /**
     * 获取表情包的列数量
     *
     * @return
     */
    public int getPageColumnCount() {
        return pageColumnCount;
    }

    /**
     * 设置表情包的列数量
     *
     * @param pageColumnCount
     */
    public void setPageColumnCount(int pageColumnCount) {
        this.pageColumnCount = pageColumnCount;
    }

    /**
     * 设置表情包的封面
     *
     * @param faceIconPath
     */
    public void setFaceIconPath(String faceIconPath) {
        this.faceIconPath = faceIconPath;
    }

    /**
     * 获取表情包的名称
     *
     * @return
     */
    public String getFaceIconName() {
        return faceIconName;
    }

    /**
     * 设置表情包的名称
     *
     * @param faceIconName
     */
    public void setFaceIconName(String faceIconName) {
        this.faceIconName = faceIconName;
    }
}
