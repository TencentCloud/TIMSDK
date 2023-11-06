package com.tencent.qcloud.tuikit.tuicallkit.utils;

import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMFriendInfoResult;
import com.tencent.imsdk.v2.V2TIMManager;
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
        getUserInfoByIdList(list, callback);
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
        getUserInfoByIdList(list, callback);
    }

    //Return the remark first.If remark is empty, return the nickname. If nickname is also empty, return the userId.
    public void getUserInfoByIdList(List<String> userList, UserCallback callback) {
        if (null == userList || userList.isEmpty()) {
            TUILog.e(TAG, "getUserInfo, userIdList is empty");
            if (callback != null) {
                callback.onFailed(-1, ERROR_MSG_EMPTY_LIST);
            }
            return;
        }
        V2TIMManager.getFriendshipManager().getFriendsInfo(userList,
                new V2TIMValueCallback<List<V2TIMFriendInfoResult>>() {
                    @Override
                    public void onError(int errorCode, String errorMsg) {
                        TUILog.e(TAG, "getUserInfo failed, errorCode: " + errorCode + ", errorMsg: " + errorMsg);
                        if (callback != null) {
                            callback.onFailed(errorCode, errorMsg);
                        }
                    }

                    @Override
                    public void onSuccess(List<V2TIMFriendInfoResult> v2TIMFriendInfoResults) {
                        if (v2TIMFriendInfoResults == null || v2TIMFriendInfoResults.isEmpty()) {
                            TUILog.e(TAG, "getUserInfo result is empty");
                            if (null != callback) {
                                callback.onFailed(-1, ERROR_MSG_EMPTY_LIST);
                            }
                            return;
                        }

                        List<CallingUserModel> list = new ArrayList<>();
                        for (V2TIMFriendInfoResult result : v2TIMFriendInfoResults) {
                            if (result == null) {
                                continue;
                            }
                            CallingUserModel model = new CallingUserModel();

                            V2TIMFriendInfo friendInfo = result.getFriendInfo();
                            model.userId = friendInfo.getUserID();
                            model.userName = friendInfo.getFriendRemark();

                            if (TextUtils.isEmpty(model.userName)) {
                                String nickName = friendInfo.getUserProfile().getNickName();
                                model.userName = TextUtils.isEmpty(nickName) ? friendInfo.getUserID() : nickName;
                            }

                            model.userAvatar = friendInfo.getUserProfile().getFaceUrl();
                            if (!isUrl(model.userAvatar)) {
                                model.userAvatar = "";
                            }
                            list.add(model);
                        }
                        TUILog.i(TAG, "getUserInfo, list: " + list);
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
