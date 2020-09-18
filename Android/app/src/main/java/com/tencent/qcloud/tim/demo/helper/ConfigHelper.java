package com.tencent.qcloud.tim.demo.helper;

import android.os.Environment;

import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.component.face.CustomFace;
import com.tencent.qcloud.tim.uikit.component.face.CustomFaceGroup;
import com.tencent.qcloud.tim.uikit.config.CustomFaceConfig;
import com.tencent.qcloud.tim.uikit.config.GeneralConfig;
import com.tencent.qcloud.tim.uikit.config.TUIKitConfigs;

import java.io.File;

public class ConfigHelper {

    public ConfigHelper() {

    }

    public TUIKitConfigs getConfigs() {
        GeneralConfig config = new GeneralConfig();
        // 显示对方是否已读的view将会展示
        config.setShowRead(true);
        config.setAppCacheDir(DemoApplication.instance().getFilesDir().getPath());
        if (new File(Environment.getExternalStorageDirectory() + "/111222333").exists()) {
            config.setTestEnv(true);
        }
        TUIKit.getConfigs().setGeneralConfig(config);
        TUIKit.getConfigs().setCustomFaceConfig(initCustomFaceConfig());
        return TUIKit.getConfigs();
    }

    private CustomFaceConfig initCustomFaceConfig() {
        //创建一个表情组对象
//        CustomFaceGroup faceConfigs = new CustomFaceGroup();
//        //设置表情组每页可显示的表情列数
//        faceConfigs.setPageColumnCount(5);
//        //设置表情组每页可显示的表情行数
//        faceConfigs.setPageRowCount(2);
//        //设置表情组号
//        faceConfigs.setFaceGroupId(1);
//        //设置表情组的主ICON
//        faceConfigs.setFaceIconPath("4349/xx07@2x.png");
//        //设置表情组的名称
//        faceConfigs.setFaceIconName("4350");
//        for (int i = 1; i <= 15; i++) {
//            //创建一个表情对象
//            CustomFaceConfig faceConfig = new CustomFaceConfig();
//            String index = "" + i;
//            if (i < 10)
//                index = "0" + i;
//            //设置表情所在Asset目录下的路径
//            faceConfig.setAssetPath("4349/xx" + index + "@2x.png");
//            //设置表情所名称
//            faceConfig.setFaceName("xx" + index + "@2x");
//            //设置表情宽度
//            faceConfig.setFaceWidth(240);
//            //设置表情高度
//            faceConfig.setFaceHeight(240);
//            faceConfigs.addCustomFace(faceConfig);
//        }
//        groupFaces.add(faceConfigs);

        CustomFaceConfig config = new CustomFaceConfig();

        CustomFaceGroup faceConfigs_1 = new CustomFaceGroup();
        faceConfigs_1.setPageColumnCount(5);
        faceConfigs_1.setPageRowCount(2);
        faceConfigs_1.setFaceGroupId(1);
        faceConfigs_1.setFaceIconPath("4350/yz00@2x.png");
        faceConfigs_1.setFaceIconName("4350");
        for (int i = 0; i <= 17; i++) {
            CustomFace customFace = new CustomFace();
            String index = "" + i;
            if (i < 10)
                index = "0" + i;
            customFace.setAssetPath("4350/yz" + index + "@2x.png");
            customFace.setFaceName("yz" + index + "@2x");
            customFace.setFaceWidth(170);
            customFace.setFaceHeight(170);
            faceConfigs_1.addCustomFace(customFace);
        }
        config.addFaceGroup(faceConfigs_1);

        CustomFaceGroup faceConfigs_2 = new CustomFaceGroup();
        faceConfigs_2.setPageColumnCount(5);
        faceConfigs_2.setPageRowCount(2);
        faceConfigs_2.setFaceGroupId(2);
        faceConfigs_2.setFaceIconPath("4351/ys00@2x.png");
        faceConfigs_2.setFaceIconName("4351");
        for (int i = 0; i <= 15; i++) {
            CustomFace customFace = new CustomFace();
            String index = "" + i;
            if (i < 10)
                index = "0" + i;
            customFace.setAssetPath("4351/ys" + index + "@2x.png");
            customFace.setFaceName("ys" + index + "@2x");
            customFace.setFaceWidth(170);
            customFace.setFaceHeight(170);
            faceConfigs_2.addCustomFace(customFace);
        }
        config.addFaceGroup(faceConfigs_2);

        CustomFaceGroup faceConfigs_3 = new CustomFaceGroup();
        faceConfigs_3.setPageColumnCount(5);
        faceConfigs_3.setPageRowCount(2);
        faceConfigs_3.setFaceGroupId(3);
        faceConfigs_3.setFaceIconPath("4352/gcs00@2x.png");
        faceConfigs_3.setFaceIconName("4352");
        for (int i = 0; i <= 16; i++) {
            CustomFace customFace = new CustomFace();
            String index = "" + i;
            if (i < 10)
                index = "0" + i;
            customFace.setAssetPath("4352/gcs" + index + "@2x.png");
            customFace.setFaceName("gcs" + index + "@2x");
            customFace.setFaceWidth(170);
            customFace.setFaceHeight(170);
            faceConfigs_3.addCustomFace(customFace);
        }
        config.addFaceGroup(faceConfigs_3);

        return config;
    }

}
