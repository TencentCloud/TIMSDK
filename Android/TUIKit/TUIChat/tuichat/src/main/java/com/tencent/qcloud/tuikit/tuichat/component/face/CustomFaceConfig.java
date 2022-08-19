package com.tencent.qcloud.tuikit.tuichat.component.face;

import java.util.ArrayList;
import java.util.List;

/**
 * 自定义表情包的配置类
 * 
 * Configuration class for custom emoticons
 */
public class CustomFaceConfig {

    private List<CustomFaceGroup> mFaceConfigs;

    /**
     * 增加自定义表情包
     * 
     * Add custom emoji
     *
     * @param group
     * @return
     */
    public CustomFaceConfig addFaceGroup(CustomFaceGroup group) {
        if (mFaceConfigs == null) {
            mFaceConfigs = new ArrayList<CustomFaceGroup>();
        }
        mFaceConfigs.add(group);
        return this;
    }

    /**
     * 获取全部的自定义表情包
     * 
     * Get all custom emojis
     *
     * @return
     */
    public List<CustomFaceGroup> getFaceGroups() {
        return mFaceConfigs;
    }

}
