package com.tencent.qcloud.tim.uikit.config;

import com.tencent.imsdk.v2.V2TIMSDKConfig;

public class TUIKitConfigs {

    private static TUIKitConfigs sConfigs;
    private GeneralConfig generalConfig;
    private CustomFaceConfig customFaceConfig;
    private V2TIMSDKConfig sdkConfig;
    private boolean mEnableGroupLiveEntry = true;

    private TUIKitConfigs() {

    }

    /**
     * 获取TUIKit的全部配置
     *
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
     *
     * @return
     */
    public GeneralConfig getGeneralConfig() {
        return generalConfig;
    }

    /**
     * 设置TUIKit的通用配置
     *
     * @param generalConfig
     * @return
     */
    public TUIKitConfigs setGeneralConfig(GeneralConfig generalConfig) {
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
    public TUIKitConfigs setCustomFaceConfig(CustomFaceConfig customFaceConfig) {
        this.customFaceConfig = customFaceConfig;
        return this;
    }

    /**
     * 获取IMSDK的配置
     *
     * @return
     */
    public V2TIMSDKConfig getSdkConfig() {
        return sdkConfig;
    }

    /**
     * 设置IMSDK的配置
     *
     * @param timSdkConfig
     * @return
     */
    public TUIKitConfigs setSdkConfig(V2TIMSDKConfig timSdkConfig) {
        this.sdkConfig = timSdkConfig;
        return this;
    }

    /**
     * 群直播入口开关
     *
     * @param enableGroupLiveEntry true：有入口，false：无入口。默认 true
     */
    public void setEnableGroupLiveEntry(boolean enableGroupLiveEntry) {
        mEnableGroupLiveEntry = enableGroupLiveEntry;
    }

    public boolean isEnableGroupLiveEntry() {
        return mEnableGroupLiveEntry;
    }

}
