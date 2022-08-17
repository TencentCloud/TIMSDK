package com.qq.qcloud.tencent_im_sdk_plugin.manager;

import com.qq.qcloud.tencent_im_sdk_plugin.util.AbCallback;
import com.qq.qcloud.tencent_im_sdk_plugin.util.CommonUtil;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMOfflinePushConfig;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class OfflinePushManager {
    private static MethodChannel channel;
    public OfflinePushManager(MethodChannel _channel){
        OfflinePushManager.channel = _channel;
    }

    public void setOfflinePushConfig(final MethodCall methodCall, final MethodChannel.Result result){
        CommonUtil.checkAbility(methodCall, new AbCallback() {
            @Override
            public void onAbSuccess() {
                Double businessID = CommonUtil.getParam(methodCall,result,"businessID");
                String token = CommonUtil.getParam(methodCall,result,"token");
                boolean isTPNSToken = CommonUtil.getParam(methodCall,result,"isTPNSToken");
                V2TIMManager.getOfflinePushManager().setOfflinePushConfig(new V2TIMOfflinePushConfig(new Double(businessID).longValue(),token, isTPNSToken), new V2TIMCallback() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtil.returnError(result,i,s);
                    }

                    @Override
                    public void onSuccess() {
                        CommonUtil.returnSuccess(result,null);
                    }
                });
            }

            @Override
            public void onAbError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void doBackground(final MethodCall methodCall, final MethodChannel.Result result){
        CommonUtil.checkAbility(methodCall, new AbCallback() {
            @Override
            public void onAbSuccess() {
                int unreadCount = CommonUtil.getParam(methodCall,result,"unreadCount");
                V2TIMManager.getOfflinePushManager().doBackground(unreadCount, new V2TIMCallback() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtil.returnError(result,i,s);
                    }

                    @Override
                    public void onSuccess() {
                        CommonUtil.returnSuccess(result,null);
                    }
                });
            }

            @Override
            public void onAbError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void doForeground(MethodCall methodCall, final MethodChannel.Result result){
        CommonUtil.checkAbility(methodCall, new AbCallback() {
            @Override
            public void onAbSuccess() {
                V2TIMManager.getOfflinePushManager().doForeground(new V2TIMCallback() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtil.returnError(result,i,s);
                    }

                    @Override
                    public void onSuccess() {
                        CommonUtil.returnSuccess(result,null);
                    }
                });
            }

            @Override
            public void onAbError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });

    }

}
