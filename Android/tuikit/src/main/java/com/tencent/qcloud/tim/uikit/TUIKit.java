package com.tencent.qcloud.tim.uikit;

import android.content.Context;

import com.tencent.qcloud.tim.uikit.base.IMEventListener;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.config.TUIKitConfigs;

public class TUIKit {

    /**
     * TUIKit的初始化函数
     *
     * @param context  应用的上下文，一般为对应应用的ApplicationContext
     * @param sdkAppID 您在腾讯云注册应用时分配的sdkAppID
     * @param configs  TUIKit的相关配置项，一般使用默认即可，需特殊配置参考API文档
     */
    public static void init(Context context, int sdkAppID, TUIKitConfigs configs) {
        TUIKitImpl.init(context, sdkAppID, configs);
    }

    /**
     * 释放一些资源等，一般可以在退出登录时调用
     */
    public static void unInit() {
        TUIKitImpl.unInit();
    }

    /**
     * 获取TUIKit保存的上下文Context，该Context会长期持有，所以应该为Application级别的上下文
     *
     * @return
     */
    public static Context getAppContext() {
        return TUIKitImpl.getAppContext();
    }

    /**
     * 获取TUIKit的全部配置
     *
     * @return
     */
    public static TUIKitConfigs getConfigs() {
        return TUIKitImpl.getConfigs();
    }

    /**
     * 设置TUIKit的IM消息的全局监听
     *
     * @param listener
     */
    public static void setIMEventListener(IMEventListener listener) {
        TUIKitImpl.setIMEventListener(listener);
    }

    /**
     * 用户IM登录
     *
     * @param userid   用户名
     * @param usersig  从业务服务器获取的usersig
     * @param callback 登录是否成功的回调
     */
    public static void login(String userid, String usersig, final IUIKitCallBack callback) {
        TUIKitImpl.login(userid, usersig, callback);
    }
}
