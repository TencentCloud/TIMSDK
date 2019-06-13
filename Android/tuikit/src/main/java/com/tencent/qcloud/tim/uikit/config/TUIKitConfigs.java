package com.tencent.qcloud.tim.uikit.config;

import com.tencent.imsdk.TIMSdkConfig;

public class TUIKitConfigs {

    private GeneralConfig generalConfig;
    private CustomFaceConfig customFaceConfig;
    private TIMSdkConfig sdkConfig;

    private static TUIKitConfigs sConfigs;

    private TUIKitConfigs() {

    }

    /**
     * 获取TUIKit的全部配置
     * @return
     */
    public static TUIKitConfigs getConfigs() {
        if (sConfigs == null) {
            sConfigs = new TUIKitConfigs();
        }
        return sConfigs;
    }

    /**
     * 获取TUIKit的通用配置
     * @return
     */
    public GeneralConfig getGeneralConfig() {
        return generalConfig;
    }

    /**
     * 设置TUIKit的通用配置
     * @param generalConfig
     * @return
     */
    public TUIKitConfigs setGeneralConfig(GeneralConfig generalConfig) {
        this.generalConfig = generalConfig;
        return this;
    }

    /**
     * 获取自定义表情包配置
     * @return
     */
    public CustomFaceConfig getCustomFaceConfig() {
        return customFaceConfig;
    }

    /**
     * 设置自定义表情包配置
     * @param customFaceConfig
     * @return
     */
    public TUIKitConfigs setCustomFaceConfig(CustomFaceConfig customFaceConfig) {
        this.customFaceConfig = customFaceConfig;
        return this;
    }

    /**
     * 获取IMSDK的配置
     * @return
     */
    public TIMSdkConfig getSdkConfig() {
        return sdkConfig;
    }

    /**
     * 设置IMSDK的配置
     * @param timSdkConfig
     * @return
     */
    public TUIKitConfigs setSdkConfig(TIMSdkConfig timSdkConfig) {
        this.sdkConfig = timSdkConfig;
        return this;
    }
}
