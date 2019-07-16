package com.tencent.qcloud.tim.uikit.component.face;

/**
 * 自定义表情属性类
 */
public class CustomFace {

    private String assetPath;
    private String faceName;
    private int faceWidth;
    private int faceHeight;

    /**
     * 获取表情在asset中的路径
     *
     * @return
     */
    public String getAssetPath() {
        return assetPath;
    }

    /**
     * 设置表情在asset中的路径
     *
     * @param assetPath
     */
    public void setAssetPath(String assetPath) {
        this.assetPath = assetPath;
    }

    /**
     * 获取表情名字
     *
     * @return
     */
    public String getFaceName() {
        return faceName;
    }

    /**
     * 设置表情名字
     *
     * @param faceName
     */
    public void setFaceName(String faceName) {
        this.faceName = faceName;
    }

    /**
     * 获取表情的宽
     *
     * @return
     */
    public int getFaceWidth() {
        return faceWidth;
    }

    /**
     * 设置表情的宽
     *
     * @param faceWidth
     */
    public void setFaceWidth(int faceWidth) {
        this.faceWidth = faceWidth;
    }

    /**
     * 获取表情的高
     *
     * @return
     */
    public int getFaceHeight() {
        return faceHeight;
    }

    /**
     * 设置表情的高
     *
     * @param faceHeight
     */
    public void setFaceHeight(int faceHeight) {
        this.faceHeight = faceHeight;
    }
}
