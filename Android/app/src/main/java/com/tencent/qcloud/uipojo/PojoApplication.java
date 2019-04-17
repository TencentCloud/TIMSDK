package com.tencent.qcloud.uipojo;

import android.app.Application;

import com.huawei.android.hms.agent.HMSAgent;
import com.meizu.cloud.pushsdk.PushManager;
import com.meizu.cloud.pushsdk.util.MzSystemUtils;
import com.tencent.imsdk.session.SessionWrapper;
import com.tencent.imsdk.utils.IMFunc;
import com.tencent.qcloud.uikit.BaseUIKitConfigs;
import com.tencent.qcloud.uikit.IMEventListener;
import com.tencent.qcloud.uikit.TUIKit;
import com.tencent.qcloud.uikit.business.chat.view.widget.CustomFaceGroupConfigs;
import com.tencent.qcloud.uikit.business.chat.view.widget.FaceConfig;
import com.tencent.qcloud.uikit.common.utils.UIUtils;
import com.tencent.qcloud.uipojo.main.MainActivity;
import com.tencent.qcloud.uipojo.utils.Constants;
import com.vivo.push.PushClient;
import com.xiaomi.mipush.sdk.MiPushClient;

import java.util.ArrayList;

/**
 * Created by valexhuang on 2018/6/21.
 */

public class PojoApplication extends Application {

    private static PojoApplication instance;

    @Override
    public void onCreate() {
        super.onCreate();
        //判断是否是在主线程
        if (SessionWrapper.isMainProcess(getApplicationContext())) {
            /**
             * TUIKit的初始化函数
             *
             * @param context  应用的上下文，一般为对应应用的ApplicationContext
             * @param sdkAppID 您在腾讯云注册应用时分配的sdkAppID
             * @param configs  TUIKit的相关配置项，一般使用默认即可，需特殊配置参考API文档
             */
            long current = System.currentTimeMillis();
            TUIKit.init(this, Constants.SDKAPPID, BaseUIKitConfigs.getDefaultConfigs());
            System.out.println(">>>>>>>>>>>>>>>>>>"+(System.currentTimeMillis()-current));
            //添加自定初始化配置
            customConfig();
            System.out.println(">>>>>>>>>>>>>>>>>>"+(System.currentTimeMillis()-current));

            if(IMFunc.isBrandXiaoMi()){
                // 小米离线推送
                MiPushClient.registerPush(this, Constants.XM_PUSH_APPID, Constants.XM_PUSH_APPKEY);
            }
            if(IMFunc.isBrandHuawei()){
                // 华为离线推送
                HMSAgent.init(this);
            }
            if(MzSystemUtils.isBrandMeizu(this)){
                // 魅族离线推送
                PushManager.register(this, Constants.MZ_PUSH_APPID, Constants.MZ_PUSH_APPKEY);
            }
            if(IMFunc.isBrandVivo()){
                // vivo离线推送
                PushClient.getInstance(getApplicationContext()).initialize();
            }
        }
        instance = this;
       /* if (LeakCanary.isInAnalyzerProcess(this)) {
            return;
        }
        LeakCanary.install(this);*/


    }

    private void customConfig() {
        if (TUIKit.getBaseConfigs() != null) {
            //注册IM事件回调，这里示例为用户被踢的回调，更多事件注册参考文档
            TUIKit.getBaseConfigs().setIMEventListener(new IMEventListener() {
                @Override
                public void onForceOffline() {
                    UIUtils.toastLongMessage("您的账号已在其它终端登录");
                    MainActivity.login(false);
                }
            });
            //添加自定义表情
            //TUIKit.getBaseConfigs().setFaceConfigs(initCustomConfig());

        }
    }


    private ArrayList<CustomFaceGroupConfigs> initCustomConfig() {
        ArrayList<CustomFaceGroupConfigs> groupFaces = new ArrayList<>();
        //创建一个表情组对象
        CustomFaceGroupConfigs faceConfigs = new CustomFaceGroupConfigs();
        //设置表情组每页可显示的表情列数
        faceConfigs.setPageColumnCount(5);
        //设置表情组每页可显示的表情行数
        faceConfigs.setPageRowCount(2);
        //设置表情组号
        faceConfigs.setFaceGroupId(1);
        //设置表情组的主ICON
        faceConfigs.setFaceIconPath("4349/xx07@2x.png");
        //设置表情组的名称
        faceConfigs.setFaceIconName("4350");
        for (int i = 1; i <= 15; i++) {
            //创建一个表情对象
            FaceConfig faceConfig = new FaceConfig();
            String index = "" + i;
            if (i < 10)
                index = "0" + i;
            //设置表情所在Asset目录下的路径
            faceConfig.setAssetPath("4349/xx" + index + "@2x.png");
            //设置表情所名称
            faceConfig.setFaceName("xx" + index + "@2x");
            //设置表情宽度
            faceConfig.setFaceWidth(240);
            //设置表情高度
            faceConfig.setFaceHeight(240);
            faceConfigs.addFaceConfig(faceConfig);
        }
        groupFaces.add(faceConfigs);


        faceConfigs = new CustomFaceGroupConfigs();
        faceConfigs.setPageColumnCount(5);
        faceConfigs.setPageRowCount(2);
        faceConfigs.setFaceGroupId(1);
        faceConfigs.setFaceIconPath("4350/tt01@2x.png");
        faceConfigs.setFaceIconName("4350");
        for (int i = 1; i <= 16; i++) {
            FaceConfig faceConfig = new FaceConfig();
            String index = "" + i;
            if (i < 10)
                index = "0" + i;
            faceConfig.setAssetPath("4350/tt" + index + "@2x.png");
            faceConfig.setFaceName("tt" + index + "@2x");
            faceConfig.setFaceWidth(240);
            faceConfig.setFaceHeight(240);
            faceConfigs.addFaceConfig(faceConfig);
        }
        groupFaces.add(faceConfigs);


        return groupFaces;
    }


    public static PojoApplication instance() {
        return instance;
    }

}
