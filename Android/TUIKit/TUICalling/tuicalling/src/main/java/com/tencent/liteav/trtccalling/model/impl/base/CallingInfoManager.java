package com.tencent.liteav.trtccalling.model.impl.base;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.liteav.trtccalling.model.impl.UserModel;

import java.util.ArrayList;
import java.util.List;

public class CallingInfoManager {
    private static CallingInfoManager sInstance;
    private static final String TAG = "CallingInfoManager";

    public static CallingInfoManager getInstance() {
        if (sInstance == null) {
            synchronized (CallingInfoManager.class) {
                if (sInstance == null) {
                    sInstance = new CallingInfoManager();
                }
            }
        }
        return sInstance;
    }

    public void getUserInfoByUserId(final String userId, final UserCallback callback) {
        if (TextUtils.isEmpty(userId)) {
            Log.e(TAG, "get user info list fail, user list is empty.");
            if (callback != null) {
                callback.onFailed(-1, "get user info list fail, user list is empty.");
            }
            return;
        }
        List<String> userList = new ArrayList<>();
        userList.add(userId);
        Log.i(TAG, "get user info list " + userList);
        V2TIMManager.getInstance().getUsersInfo(userList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onError(int i, String s) {
                Log.e(TAG, "get user info list fail, code:" + i);
                if (callback != null) {
                    callback.onFailed(i, s);
                }
            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                List<UserModel> list = new ArrayList<>();
                if (v2TIMUserFullInfos != null && v2TIMUserFullInfos.size() != 0) {
                    for (int i = 0; i < v2TIMUserFullInfos.size(); i++) {
                        UserModel model = new UserModel();
                        model.userName = v2TIMUserFullInfos.get(i).getNickName();
                        model.userId = v2TIMUserFullInfos.get(i).getUserID();
                        model.userAvatar = v2TIMUserFullInfos.get(i).getFaceUrl();
                        list.add(model);
                        Log.d(TAG, String.format("getUserInfoByUserId, userId=%s, userName=%s, userAvatar=%s", model.userId, model.userName, model.userAvatar));
                        if (TextUtils.isEmpty(model.userName)) {
                            model.userName = model.userId;
                        }
                    }
                }
                if (callback != null) {
                    callback.onSuccess(list.get(0));
                }
            }
        });
    }



    // 通过userid/phone获取用户信息回调
    public interface UserCallback {
        void onSuccess(UserModel model);
        void onFailed(int code, String msg);
    }
}
