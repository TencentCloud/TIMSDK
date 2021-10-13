package com.tencent.qcloud.tuikit.tuichat.config;

import com.tencent.imsdk.v2.V2TIMSDKConfig;
import com.tencent.qcloud.tuikit.tuichat.component.face.CustomFaceConfig;

public class TUIChatConfigs {

    private static TUIChatConfigs sConfigs;
    private GeneralConfig generalConfig;
    private CustomFaceConfig customFaceConfig;

    private TUIChatConfigs() {

    }

    /**
     * 获取TUIKit的全部配置
     *
     * @return
     */
    public static TUIChatConfigs getConfigs() {
        if (sConfigs == null) {
            sConfigs = new TUIChatConfigs();
        }
        return sConfigs;
    }

    /**
     * 获取TUIKit的通用配置
     *
     * @return
     */
    public GeneralConfig getGeneralConfig() {
        if (generalConfig == null) {
            generalConfig = new GeneralConfig();
        }
        return generalConfig;
    }

    /**
     * 设置TUIKit的通用配置
     *
     * @param generalConfig
     * @return
     */
    public TUIChatConfigs setGeneralConfig(GeneralConfig generalConfig) {
        this.generalConfig = generalConfig;
        return this;
    }

    /**
     * 获取自定义表情包配置
     *
     * @return
     */
    public CustomFaceConfig getCustomFaceConfig() {
        return customFaceConfig;
    }

    /**
     * 设置自定义表情包配置
     *
     * @param customFaceConfig
     * @return
     */
    public TUIChatConfigs setCustomFaceConfig(CustomFaceConfig customFaceConfig) {
        this.customFaceConfig = customFaceConfig;
        return this;
    }

}
