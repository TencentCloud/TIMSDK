package com.reactnativetimjs.manager;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMap;

import com.reactnativetimjs.util.CommonUtils;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMOfflinePushConfig;

public class OfflinePushManager {
    public void setOfflinePushConfig(Promise promise, ReadableMap arguments) {
        Double businessID = arguments.getDouble("businessID");
        String token = arguments.getString("token");
        boolean isTPNSToken = arguments.getBoolean("isTPNSToken");
        V2TIMManager.getOfflinePushManager().setOfflinePushConfig(
                new V2TIMOfflinePushConfig(businessID.longValue(), token, isTPNSToken),
                new V2TIMCallback() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }

                    @Override
                    public void onSuccess() {
                        CommonUtils.returnSuccess(promise, null);
                    }
                });
    }

    public void doBackground(Promise promise, ReadableMap arguments) {
        int unreadCount = arguments.getInt("unreadCount");
        V2TIMManager.getOfflinePushManager().doBackground(unreadCount, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }
        });
    }

    public void doForeground(Promise promise, ReadableMap arguments) {
        V2TIMManager.getOfflinePushManager().doForeground(new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }
        });
    }

}
