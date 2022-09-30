package com.tencent.qcloud.tuikit.tuichat.component.face;

/**
 * 自定义表情属性类
 * 
 * Custom expression attribute class
 */
public class CustomFace extends ChatFace {

    /**
     * 设置表情在asset中的路径
     *
     * @param assetPath
     */
    public void setAssetPath(String assetPath) {
        this.faceUrl = "file:///android_asset/" + assetPath;
    }
}
