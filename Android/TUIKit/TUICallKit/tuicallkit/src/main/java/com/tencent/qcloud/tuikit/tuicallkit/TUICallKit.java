package com.tencent.qcloud.tuikit.tuicallkit;

import android.content.Context;

import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;

import java.util.List;

public abstract class TUICallKit {

    public static TUICallKit createInstance(Context context) {
        return TUICallKitImpl.createInstance(context);
    }

    /**
     * Set user profile
     *
     * @param nickname User name, which can contain up to 500 bytes
     * @param avatar   User profile photo URL, which can contain up to 500 bytes
     *                 For example: https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png
     * @param callback Set the result callback
     */
    public void setSelfInfo(String nickname, String avatar, TUICommonDefine.Callback callback) {
    }

    /**
     * Make a call
     *
     * @param userId        callees
     * @param callMediaType Call type
     */
    public void call(String userId, TUICallDefine.MediaType callMediaType) {
    }

    /**
     * Make a call
     *
     * @param userId        callees
     * @param callMediaType Call type
     * @param params        Extension param: eg: offlinePushInfo
     */
    public void call(String userId, TUICallDefine.MediaType callMediaType,
                     TUICallDefine.CallParams params, TUICommonDefine.Callback callback) {
    }

    /**
     * Make a group call
     *
     * @param groupId       GroupId
     * @param userIdList    List of userId
     * @param callMediaType Call type
     */
    public void groupCall(String groupId, List<String> userIdList, TUICallDefine.MediaType callMediaType) {
    }

    /**
     * Make a group call
     *
     * @param groupId       GroupId
     * @param userIdList    List of userId
     * @param callMediaType Call type
     * @param params        Extension param: eg: offlinePushInfo
     */
    public void groupCall(String groupId, List<String> userIdList,
                          TUICallDefine.MediaType callMediaType, TUICallDefine.CallParams params,
                          TUICommonDefine.Callback callback) {
    }

    /**
     * Join a current call
     *
     * @param roomId        current call room ID
     * @param callMediaType call type
     */
    public void joinInGroupCall(TUICommonDefine.RoomId roomId, String groupId, TUICallDefine.MediaType callMediaType) {
    }

    /**
     * Set the ringtone (preferably shorter than 30s)
     *
     * @param filePath Callee ringtone path
     */
    public void setCallingBell(String filePath) {
    }

    /**
     * Enable the mute mode (the callee doesn't ring)
     */
    public void enableMuteMode(boolean enable) {
    }

    /**
     * Enable the floating window
     */
    public void enableFloatWindow(boolean enable) {
    }
}
