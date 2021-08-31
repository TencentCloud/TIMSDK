package com.tencent.liteav.login;

import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.tuikit.live.utils.TUILiveLog;

import java.util.ArrayList;
import java.util.List;

public class ProfileManager {
    private static final ProfileManager ourInstance = new ProfileManager();


    private final static String PER_DATA       = "per_profile_manager";
    private final static String PER_USER_MODEL = "per_user_model";
    private static final String PER_USER_ID    = "per_user_id";
    private static final String PER_TOKEN      = "per_user_token";
    private static final String TAG            = ProfileManager.class.getName();

    private UserModel mUserModel;
    private String mUserId;
    private String mToken;
    private boolean   isLogin = false;

    public static ProfileManager getInstance() {
        return ourInstance;
    }

    private ProfileManager() {
    }

    public boolean isLogin() {
        return isLogin;
    }

    public UserModel getUserModel() {
        if (mUserModel == null) {
            mUserModel = new UserModel();
        }
        return mUserModel;
    }

    public String getUserId() {
        return mUserId;
    }

    public void setUserId(String userId) {
        mUserId = userId;
    }

    public void setUserModel(UserModel model) {
        mUserModel = model;
    }

    public String getToken() {
        return mToken;
    }

    private void setToken(String token) {
        mToken = token;
    }

    public void getSms(String phone, final ActionCallback callback) {
        callback.onSuccess();
    }

    public void getUserInfoByUserId(String userId, final GetUserInfoCallback callback) {
        List<String> userIDList = new ArrayList<>();
        userIDList.add(userId);
        V2TIMManager.getInstance().getUsersInfo(userIDList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onError(int code, String desc) {
                if (callback != null) {
                    callback.onFailed(code, desc);
                }
            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                if (v2TIMUserFullInfos == null || v2TIMUserFullInfos.size() == 0) {
                    TUILiveLog.e(TAG, "getUserInfoByUserId failed, v2TIMUserFullInfos is empty");
                    return;
                }
                V2TIMUserFullInfo userFullInfo = v2TIMUserFullInfos.get(0);
                UserModel userModel = new UserModel();
                userModel.userId = userFullInfo.getUserID();
                userModel.userName = userFullInfo.getNickName();
                userModel.userAvatar = userFullInfo.getFaceUrl();
                if (callback != null) {
                    callback.onSuccess(userModel);
                }
            }
        });
    }

    public void getUserInfoBatch(List<String> userIdList, final GetUserInfoBatchCallback callback) {
        if (userIdList == null) {
            return;
        }

        V2TIMManager.getInstance().getUsersInfo(userIdList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onError(int code, String desc) {
                if (callback != null) {
                    callback.onFailed(code, desc);
                }
            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                if (v2TIMUserFullInfos == null || v2TIMUserFullInfos.size() == 0) {
                    TUILiveLog.e(TAG, "getUserInfoBatch failed, v2TIMUserFullInfos is empty");
                    return;
                }
                List<UserModel> userModelList = new ArrayList<>();
                for (V2TIMUserFullInfo userFullInfo : v2TIMUserFullInfos) {
                    UserModel userModel = new UserModel();
                    userModel.userId = userFullInfo.getUserID();
                    userModel.userName = userFullInfo.getNickName();
                    userModel.userAvatar = userFullInfo.getFaceUrl();

                    userModelList.add(userModel);
                }
                if (callback != null) {
                    callback.onSuccess(userModelList);
                }
            }
        });
    }

    private String getAvatarUrl(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return null;
        }
        byte[] bytes = userId.getBytes();
        int    index = bytes[bytes.length - 1] % 10;
        String avatarName = "avatar" + index + "_100";
        return "https://imgcache.qq.com/qcloud/public/static//" + avatarName + ".20191230.png";
    }

    // 操作回调
    public interface ActionCallback {
        void onSuccess();

        void onFailed(int code, String msg);
    }

    // 通过userid/phone获取用户信息回调
    public interface GetUserInfoCallback {
        void onSuccess(UserModel model);

        void onFailed(int code, String msg);
    }

    // 通过userId批量获取用户信息回调
    public interface GetUserInfoBatchCallback {
        void onSuccess(List<UserModel> model);

        void onFailed(int code, String msg);
    }
}
