package com.tencent.qcloud.tuikit.tuicallkit.utils;

import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog;
import com.tencent.qcloud.tuikit.tuicallkit.base.CallingUserModel;

import java.util.ArrayList;
import java.util.List;

public class UserInfoUtils {
    private static final String TAG                  = "UserInfoUtils";
    private static final String ERROR_MSG_EMPTY_LIST = "userList is empty";

    public UserInfoUtils() {
    }

    public void getUserInfo(String userId, final UserCallback callback) {
        if (TextUtils.isEmpty(userId)) {
            TUILog.e(TAG, "getUserInfo, userId is empty.");
            if (callback != null) {
                callback.onFailed(-1, ERROR_MSG_EMPTY_LIST);
            }
            return;
        }

        List<String> list = new ArrayList<>();
        list.add(userId);
        internalGetUserInfo(list, callback);
    }

    public void getUserInfo(List<CallingUserModel> userIdList, final UserCallback callback) {
        if (null == userIdList || userIdList.isEmpty()) {
            TUILog.e(TAG, "getUserInfo, userIdList is empty.");
            if (callback != null) {
                callback.onFailed(-1, ERROR_MSG_EMPTY_LIST);
            }
            return;
        }

        List<String> list = new ArrayList<>();
        for (CallingUserModel model : userIdList) {
            if (null != model && !TextUtils.isEmpty(model.userId)) {
                list.add(model.userId);
            }
        }
        internalGetUserInfo(list, callback);
    }

    private void internalGetUserInfo(List<String> userList, UserCallback callback) {
        if (null == userList || userList.isEmpty()) {
            TUILog.e(TAG, "internalGetUserInfo, userIdList is empty.");
            if (callback != null) {
                callback.onFailed(-1, ERROR_MSG_EMPTY_LIST);
            }
            return;
        }

        V2TIMManager.getInstance().getUsersInfo(userList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onError(int errorCode, String errorMsg) {
                TUILog.e(TAG, "internalGetUserInfo fail, errorCode: " + errorCode + ", errorMsg: " + errorMsg);
                if (callback != null) {
                    callback.onFailed(errorCode, errorMsg);
                }
            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> userFullInfoList) {
                if (null == userFullInfoList || userFullInfoList.isEmpty()) {
                    TUILog.e(TAG, "internalGetUserInfo result is empty");
                    if (null != callback) {
                        callback.onFailed(-1, ERROR_MSG_EMPTY_LIST);
                    }
                    return;
                }

                List<CallingUserModel> list = new ArrayList<>();
                for (int i = 0; i < userFullInfoList.size(); i++) {
                    CallingUserModel model = new CallingUserModel();
                    model.userName = userFullInfoList.get(i).getNickName();
                    model.userId = userFullInfoList.get(i).getUserID();
                    model.userAvatar = userFullInfoList.get(i).getFaceUrl();

                    if (!isUrl(model.userAvatar)) {
                        model.userAvatar = "";
                    }

                    model.userName = TextUtils.isEmpty(model.userName) ? model.userId : model.userName;
                    TUILog.i(TAG, "internalGetUserInfo, model: " + model);
                    list.add(model);
                }
                if (callback != null) {
                    callback.onSuccess(list);
                }
            }
        });
    }

    private boolean isUrl(String url) {
        return !TextUtils.isEmpty(url) && (url.startsWith("http://") || url.startsWith("https://"));
    }

    public interface UserCallback {
        void onSuccess(List<CallingUserModel> list);

        void onFailed(int errorCode, String errorMsg);
    }
}
