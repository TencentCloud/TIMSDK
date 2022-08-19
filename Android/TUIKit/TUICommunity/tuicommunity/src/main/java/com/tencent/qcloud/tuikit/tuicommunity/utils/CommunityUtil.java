package com.tencent.qcloud.tuikit.tuicommunity.utils;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.text.TextUtils;

import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;

public class CommunityUtil {

    public static <T> void callbackOnSuccess(IUIKitCallback<T> callback, T data) {
        if (callback != null) {
            callback.onSuccess(data);
        }
    }

    public static <T> void callbackOnError(IUIKitCallback<T> callback, int errorCode, String errorMessage) {
        if (callback != null) {
            callback.onError(null , errorCode, errorMessage);
        }
    }

    public static boolean isCommunityGroup(String groupId) {
        return !TextUtils.isEmpty(groupId) && groupId.startsWith("@TGS#_");
    }

    public static boolean isTopicGroup(String groupID) {
        // topicID 格式：@TGS#_xxxx@TOPIC#_xxxx
        if (!isCommunityGroup(groupID)) {
            return false;
        }
        return groupID.contains("@TOPIC#_");
    }

    public static String getGroupIDFromTopicID(String topicID) {
        // topicID 格式：@TGS#_xxxx@TOPIC#_xxxx
        int index = topicID.indexOf("@TOPIC#_");
        return topicID.substring(0, index);
    }

    public static void openWebUrl(Context context, String url) {
        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_VIEW);
        Uri contentUrl = Uri.parse(url);
        intent.setData(contentUrl);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

}
