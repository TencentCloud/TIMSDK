package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.model;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.TUICustomerServiceConstants;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.util.TUICustomerServiceLog;
import java.util.ArrayList;
import java.util.List;

public class TUICustomerServiceProvider {
    private static final String TAG = "TUICustomerServiceProvider";
    public TUICustomerServiceProvider() {}

    public void getCustomerServiceUserInfo(V2TIMValueCallback<List<V2TIMUserFullInfo>> callback) {
        List<String> userList = new ArrayList<>();
        userList.add(TUICustomerServiceConstants.CUSTOMER_SERVICE_STAFF_SHOPPING_MALL);
        userList.add(TUICustomerServiceConstants.CUSTOMER_SERVICE_STAFF_ONLINE_DOCTOR);
        V2TIMManager.getInstance().getUsersInfo(userList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                if (callback != null) {
                    callback.onSuccess(v2TIMUserFullInfos);
                }
            }

            @Override
            public void onError(int code, String desc) {
                TUICustomerServiceLog.e(TAG, "getCustomerServiceUserInfo error:" + code + ", desc:" + desc);
            }
        });
    }
}
