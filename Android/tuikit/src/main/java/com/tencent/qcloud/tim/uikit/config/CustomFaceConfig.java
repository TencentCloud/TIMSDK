package com.tencent.qcloud.tim.uikit.config;

import com.tencent.qcloud.tim.uikit.component.face.CustomFaceGroup;

import java.util.ArrayList;
import java.util.List;

/**
 * 自定义表情包的配置类
 */
public class CustomFaceConfig {

    private List<CustomFaceGroup> mFaceConfigs;

    /**
     * 增加自定义表情包
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
     * @return
     */
    public List<CustomFaceGroup> getFaceGroups() {
        return mFaceConfigs;
    }

}
