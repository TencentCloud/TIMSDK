package com.tencent.qcloud.tuikit.tuichat.config;

import com.tencent.qcloud.tuikit.tuichat.classicui.component.noticelayout.NoticeLayoutConfig;

public class TUIChatConfigs {

    private static TUIChatConfigs sConfigs;
    private GeneralConfig generalConfig;
    private NoticeLayoutConfig noticeLayoutConfig;

    private TUIChatConfigs() {

    }

    /**
     * 获取TUIKit的全部配置
     * 
     * Get TUIKit configs
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
     * Get TUIKit general configs
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
     * Set TUIKit general configs
     *
     * @param generalConfig
     * @return
     */
    public TUIChatConfigs setGeneralConfig(GeneralConfig generalConfig) {
        this.generalConfig = generalConfig;
        return this;
    }

    /**
     * 获取聊天界面自定义视图配置
     *
     * Get chat interface custom view configuration
     *
     * @return
     */
    public NoticeLayoutConfig getNoticeLayoutConfig() {
        if (noticeLayoutConfig == null) {
            noticeLayoutConfig = new NoticeLayoutConfig();
        }
        return noticeLayoutConfig;
    }

}
