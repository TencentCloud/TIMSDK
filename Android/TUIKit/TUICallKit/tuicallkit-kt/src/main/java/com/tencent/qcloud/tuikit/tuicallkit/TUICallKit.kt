package com.tencent.qcloud.tuikit.tuicallkit

import android.content.Context
import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.TUICommonDefine.RoomId
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine.CallParams

abstract class TUICallKit {
    companion object {
        @JvmStatic
        fun createInstance(context: Context): TUICallKit = TUICallKitImpl.createInstance(context)
    }

    /**
     * Set user profile
     *
     * @param nickname User name, which can contain up to 500 bytes
     * @param avatar   User profile photo URL, which can contain up to 500 bytes
     * For example: https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png
     * @param callback Set the result callback
     */
    open fun setSelfInfo(nickname: String?, avatar: String?, callback: TUICommonDefine.Callback?) {}

    /**
     * Make a call
     *
     * @param userId        callees
     * @param callMediaType Call type
     */
    open fun call(userId: String, callMediaType: TUICallDefine.MediaType) {}

    /**
     * Make a call
     *
     * @param userId        callees
     * @param callMediaType Call type
     * @param params        Extension param: eg: offlinePushInfo
     */
    open fun call(
        userId: String, callMediaType: TUICallDefine.MediaType,
        params: CallParams?, callback: TUICommonDefine.Callback?
    ) {
    }

    /**
     * Make a group call
     *
     * @param groupId       GroupId
     * @param userIdList    List of userId
     * @param callMediaType Call type
     */
    open fun groupCall(groupId: String, userIdList: List<String?>?, callMediaType: TUICallDefine.MediaType) {}

    /**
     * Make a group call
     *
     * @param groupId       GroupId
     * @param userIdList    List of userId
     * @param callMediaType Call type
     * @param params        Extension param: eg: offlinePushInfo
     */
    open fun groupCall(
        groupId: String, userIdList: List<String?>?,
        callMediaType: TUICallDefine.MediaType, params: CallParams?,
        callback: TUICommonDefine.Callback?
    ) {
    }

    /**
     * Join a current call
     *
     * @param roomId        current call room ID
     * @param callMediaType call type
     */
    open fun joinInGroupCall(roomId: RoomId?, groupId: String?, callMediaType: TUICallDefine.MediaType?) {}

    /**
     * Set the ringtone (preferably shorter than 30s)
     *
     * @param filePath Callee ringtone path
     */
    open fun setCallingBell(filePath: String?) {}

    /**
     * Enable the mute mode (the callee doesn't ring)
     */
    open fun enableMuteMode(enable: Boolean) {}

    /**
     * Enable the floating window
     */
    open fun enableFloatWindow(enable: Boolean) {}
}