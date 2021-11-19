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
     * @note
     *  需要注意的是， TUIKit 里面的表情包都是有版权限制的，购买的 IM 服务不包括表情包的使用权，请在上线的时候替换成自己的表情包，否则会面临法律风险
     * @param customFaceConfig
     */
    public TUIChatConfigs setCustomFaceConfig(CustomFaceConfig customFaceConfig) {
        this.customFaceConfig = customFaceConfig;
        return this;
    }

}
