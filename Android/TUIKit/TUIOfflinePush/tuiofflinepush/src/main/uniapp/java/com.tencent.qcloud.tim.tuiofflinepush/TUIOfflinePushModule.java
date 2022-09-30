package com.tencent.qcloud.tim.tuiofflinepush;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.tencent.qcloud.tim.tuiofflinepush.utils.BrandUtil;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushErrorBean;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushParamBean;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushLog;
import com.tencent.qcloud.tim.tuiofflinepush.utils.TUIOfflinePushUtils;

import io.dcloud.feature.uniapp.annotation.UniJSMethod;
import io.dcloud.feature.uniapp.bridge.UniJSCallback;
import io.dcloud.feature.uniapp.common.UniModule;


public class TUIOfflinePushModule extends UniModule {

    public static final String TAG = TUIOfflinePushModule.class.getSimpleName();
    public static int REQUEST_CODE = 1000;

    public static String RESPONSE_CODE_KEY = "code";
    public static int RESPONSE_CODE_SUCCESS = 0;
    public static int RESPONSE_CODE_ERROR = -1;

    public static String RESPONSE_MSG_KEY = "msg";

    public static String RESPONSE_DATA_KEY = "data";
    public static String RESPONSE_DATA_DEVICE_TOKEN_KEY = "deviceToken";
    public static String RESPONSE_DATA_DEVICE_TYPE_KEY = "deviceType";

    public static String RESPONSE_NOTIFICATION_KEY = "notification";
    public static String RESPONSE_APPSHOW_KEY = "appShow";

    public static String RESPONSE_DATA_BUSSINESSID_KEY = "bussinessId";
    private long bussinessId = 0;

    public Context mContext = null;


    /*
     *  注册推送服务，回调推送 token
     *
     * 1、推送应用信息 options 格式为：
     *
     *  options:
     * {
     *    // huawei
     *   "huaweiPushBussinessId": "", // 在腾讯云控制台上传第三方推送证书后分配的证书ID
     *
     *   // xiaomi
     *   "xiaomiPushBussinessId": "",// 在腾讯云控制台上传第三方推送证书后分配的证书ID
     *   "xiaomiPushAppId": "",// 小米开放平台分配的应用APPID
     *   "xiaomiPushAppKey": "",// 小米开放平台分配的应用APPKEY
     *
     *   // meizu
     *   "meizuPushBussinessId": "", // 在腾讯云控制台上传第三方推送证书后分配的证书ID
     *   "meizuPushAppId": "",// 魅族开放平台分配的应用APPID
     *   "meizuPushAppKey": "",// 魅族开放平台分配的应用APPKEY
     *
     *   // vivo
     *   "vivoPushBussinessId": "", // 在腾讯云控制台上传第三方推送证书后分配的证书ID
     *
     *   // google
     *   "fcmPushBussinessId": "", // 在腾讯云控制台上传第三方推送证书后分配的证书ID
     *
     *   // oppo
     *   "oppoPushBussinessId": "", // 在腾讯云控制台上传第三方推送证书后分配的证书ID
     *   "oppoPushAppKey": "",// oppo开放平台分配的应用APPID
     *   "oppoPushAppSecret": "",// oppo开放平台分配的应用APPKEY
     *
     *   // honor
     *   "honorPushBussinessId": "",  // 在腾讯云控制台上传第三方推送证书后分配的证书ID
     *  }
     *
     * 2、回调数据 data 格式为：
     *      callback：
     *      {
     *       "code": 0,
     *       "msg": "",
     *       "data": {}
     *      }
     *
     *      data:
     *      {
     *        "deviceToken": "",
     *        "deviceType": 2002,
     *        "bussinessId":0,
     *      }
     *
     */
    //run ui thread
    @UniJSMethod(uiThread = true)
    public void getDeviceToken(JSONObject options, UniJSCallback callback) {
        TUIOfflinePushLog.d(TAG, "getDeviceToken--"+options);
        JSONObject data = new JSONObject();
        if (options == null || options.isEmpty()) {
            if (callback != null) {
                data.put(RESPONSE_CODE_KEY, RESPONSE_CODE_ERROR);
                data.put(RESPONSE_MSG_KEY, "error params");
                callback.invoke(data);
            }
            return;
        }

        if (mContext == null) {
            mContext = mUniSDKInstance.getContext();
        }

        if (mContext == null) {
            TUIOfflinePushLog.e(TAG, "mUniSDKInstance.getContext() is null");
            if (callback != null) {
                data.put(RESPONSE_CODE_KEY, RESPONSE_CODE_ERROR);
                data.put(RESPONSE_MSG_KEY, "mUniSDKInstance.getContext() is null");
                callback.invoke(data);
            }
            return;
        }

        boolean success = parseRegisterPushParams(options);
        if (success) {
            TUIOfflinePushManager.getInstance().registerPush(mContext, "", new UniJSCallback() {
                @Override
                public void invoke(Object o) {
                    /*if(callback != null) {
                        data.put(RESPONSE_CODE_KEY, RESPONSE_CODE_SUCCESS);
                        data.put(RESPONSE_MSG_KEY, "");

                        JSONObject data_data = new JSONObject();
                        data_data.put(RESPONSE_DATA_DEVICE_TOKEN_KEY, (String) o);
                        data_data.put(RESPONSE_DATA_DEVICE_TYPE_KEY, BrandUtil.getInstanceType());
                        data_data.put(RESPONSE_DATA_BUSSINESSID_KEY, bussinessId);

                        data.put(RESPONSE_DATA_KEY, data_data);
                        TUIOfflinePushLog.d(TAG, "invoke--"+data);
                        callback.invoke(data);
                    }*/
                }

                @Override
                public void invokeAndKeepAlive(Object o) {
                    if(callback != null) {
                        if (o instanceof TUIOfflinePushErrorBean) {
                            TUIOfflinePushErrorBean errorBean = (TUIOfflinePushErrorBean) o;
                            data.put(RESPONSE_CODE_KEY, errorBean.getErrorCode());
                            data.put(RESPONSE_MSG_KEY, errorBean.getErrorDescription());
                            TUIOfflinePushLog.e(TAG, "invokeAndKeepAlive--"+data);
                            callback.invokeAndKeepAlive(data);
                        } else {
                            data.put(RESPONSE_CODE_KEY, RESPONSE_CODE_SUCCESS);
                            data.put(RESPONSE_MSG_KEY, "");

                            JSONObject data_data = new JSONObject();
                            data_data.put(RESPONSE_DATA_DEVICE_TOKEN_KEY, (String) o);
                            data_data.put(RESPONSE_DATA_DEVICE_TYPE_KEY, BrandUtil.getInstanceType());
                            data_data.put(RESPONSE_DATA_BUSSINESSID_KEY, bussinessId);

                            data.put(RESPONSE_DATA_KEY, data_data);
                            TUIOfflinePushLog.d(TAG, "invokeAndKeepAlive--" + data);
                            callback.invokeAndKeepAlive(data);
                        }
                    }
                }
            });
        } else {
            TUIOfflinePushLog.e(TAG, "registerPush-- failed");
        }
    }

    /*
     *  收到推送消息，点击通知栏事件回调，透传自定义消息
     *
     *      callback：
     *      {
     *       "notification": "",
     *      }
     *
     * note：
     *   发送离线消息构建 V2TIMOfflinePushInfo，透传字段setExt的格式为 {"entity":"xxxxxx"}
     *   主要是为了和 tuikitDemo 互通
     *
     */
    //run JS thread
    @UniJSMethod (uiThread = false)
    public void setOfflinePushListener(UniJSCallback callback){
        TUIOfflinePushLog.d(TAG, "setOfflinePushListener--");
        if (callback != null) {
            TUIOfflinePushManager.getInstance().setJsNotificationCallback(callback);
        } else {
            TUIOfflinePushLog.e(TAG, "setOfflinePushListener is null");
        }
    }

    /*
     *  获取设备类型
     *
     *      return data：
     *      {
     *       "deviceType": 2002,
     *      }
     *
     */
    //run JS thread
    @UniJSMethod (uiThread = false)
    public JSONObject getDeviceType(){
        JSONObject data = new JSONObject();
        data.put(RESPONSE_DATA_DEVICE_TYPE_KEY, BrandUtil.getInstanceType());
        return data;
    }

    /*
     *  设置应用前后台回调，应用前后台状态由组件检测返回
     *
     *      callback：
     *      {
     *       "appShow": 0, // 0,后台； 1,前台
     *      }
     *
     */
    //run JS thread
    @UniJSMethod (uiThread = false)
    public void setAppShowListener(UniJSCallback callback){
        TUIOfflinePushLog.d(TAG, "setAppShowListener--");
        if (callback != null) {
            TUIOfflinePushManager.getInstance().setJsLifeCycleCallback(callback);
        } else {
            TUIOfflinePushLog.e(TAG, "setAppShowListener is null");
        }
    }

    private boolean parseRegisterPushParams(JSONObject options) {
        TUIOfflinePushParamBean tuiOfflinePushParamBean = null;
        try {
            tuiOfflinePushParamBean = JSON.toJavaObject(options, TUIOfflinePushParamBean.class);
            if (tuiOfflinePushParamBean != null) {
                bussinessId = TUIOfflinePushUtils.json2TUIOfflinePushParamBean(tuiOfflinePushParamBean);
                return true;
            }
        } catch (Exception e) {
            TUIOfflinePushLog.e(TAG, "e =" + e);
        }

        return false;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if(requestCode == REQUEST_CODE && data.hasExtra("respond")) {
            Log.e("TestModule", "原生页面返回----"+data.getStringExtra("respond"));
        } else {
            super.onActivityResult(requestCode, resultCode, data);
        }
    }

    @UniJSMethod (uiThread = true)
    public void gotoNativePage(){
        if(mUniSDKInstance != null && mUniSDKInstance.getContext() instanceof Activity) {
            /*Intent intent = new Intent(mUniSDKInstance.getContext(), NativePageActivity.class);
            ((Activity)mUniSDKInstance.getContext()).startActivityForResult(intent, REQUEST_CODE);*/
        }
    }
}
