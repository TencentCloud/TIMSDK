package com.tencent.qcloud.uikit;

import com.tencent.imsdk.TIMSdkConfig;
import com.tencent.imsdk.log.QLog;
import com.tencent.qcloud.uikit.business.chat.view.widget.CustomFaceGroupConfigs;
import com.tencent.qcloud.uikit.common.component.face.FaceManager;

import java.util.ArrayList;

public class BaseUIKitConfigs<T> {

    private static final String TAG = BaseUIKitConfigs.class.getSimpleName();

    /**
     * 文本框最大输入字符数目默认值
     *
     * 限制：单聊、群聊消息，单条消息最大长度限制为9000字节，超过此长度会被系统丢弃
     * https://cloud.tencent.com/document/product/269/32429
     * 在此我们假设默认为中文输入，最大长度为9000/2=4500
     */
    private static final int DEFAULT_MAX_INPUT_TEXT_LENGTH = 4500;

    /**
     * 配置 APP 保存图片/语音/文件/log等数据缓存的目录(一般配置在SD卡目录)
     * <p>
     * 默认为 /sdcard/{packageName}/
     */
    private String appCacheDir;

    /**
     * 文本框最大输入字符数目
     */
    private int maxInputTextLength = DEFAULT_MAX_INPUT_TEXT_LENGTH;


    /**
     * 录音时长限制，单位秒，默认最长120s
     */
    private int audioRecordMaxTime = 60;


    /**
     * 录音时长限制，单位秒，默认最长10s
     */
    private int videoRecordMaxTime = 10;


    /**
     * 自定义表情配置项
     */
    private ArrayList<CustomFaceGroupConfigs> faceConfigs;


    /**
     * 自定义表情配置项
     */
    private IMEventListener IMEventListener;


    /**
     * 自定义IMSDK配置项
     */
    private TIMSdkConfig TIMSdkConfig;


    public BaseUIKitConfigs setAppCacheDir(String appCacheDir) {
        this.appCacheDir = appCacheDir;
        return this;
    }

    /**
     * 文本框最大输入字符数目
     *
     * 请参考开发文档中对内容长度的限制：
     * https://cloud.tencent.com/document/product/269/32429
     *
     * @param maxInputTextLength
     * @return
     */
    public BaseUIKitConfigs setMaxInputTextLength(int maxInputTextLength) {
        if (maxInputTextLength > DEFAULT_MAX_INPUT_TEXT_LENGTH) {
            QLog.w(TAG, "setMaxInputTextLength failed: too long, more than: " + DEFAULT_MAX_INPUT_TEXT_LENGTH);
        } else {
            this.maxInputTextLength = maxInputTextLength;
        }
        return this;
    }

    /**
     * 录音最大时长
     *
     * @param audioRecordMaxTime
     * @return
     */
    public BaseUIKitConfigs setAudioRecordMaxTime(int audioRecordMaxTime) {
        this.audioRecordMaxTime = audioRecordMaxTime;
        return this;
    }


    /**
     * 摄像最大时长
     *
     * @param videoRecordMaxTime
     * @return
     */
    public BaseUIKitConfigs setVideoRecordMaxTime(int videoRecordMaxTime) {
        this.videoRecordMaxTime = videoRecordMaxTime;
        return this;
    }


    /**
     * 自定义表情配置
     *
     * @param faceConfigs
     * @return
     */
    public BaseUIKitConfigs setFaceConfigs(ArrayList<CustomFaceGroupConfigs> faceConfigs) {
        this.faceConfigs = faceConfigs;
        FaceManager.loadFaceFiles();
        return this;
    }


    public String getAppCacheDir() {
        return appCacheDir;
    }

    public int getMaxInputTextLength() {
        return maxInputTextLength;
    }

    public int getAudioRecordMaxTime() {
        return audioRecordMaxTime;
    }

    public int getVideoRecordMaxTime() {
        return videoRecordMaxTime;
    }

    public ArrayList<CustomFaceGroupConfigs> getFaceConfigs() {
        return faceConfigs;
    }

    public static BaseUIKitConfigs getDefaultConfigs() {
        return new BaseUIKitConfigs();
    }

    public TIMSdkConfig getTIMSdkConfig() {
        return TIMSdkConfig;
    }

    public BaseUIKitConfigs setTIMSdkConfig(com.tencent.imsdk.TIMSdkConfig TIMSdkConfig) {
        this.TIMSdkConfig = TIMSdkConfig;
        return this;
    }

    public IMEventListener getIMEventListener() {
        return IMEventListener;
    }

    public BaseUIKitConfigs setIMEventListener(com.tencent.qcloud.uikit.IMEventListener IMEventListener) {
        this.IMEventListener = IMEventListener;
        return this;
    }
}
