package com.tencent.qcloud.tuikit.tuicallkit.internal

import android.content.Context
import android.os.Bundle
import android.text.TextUtils
import android.util.Log
import androidx.activity.result.ActivityResult
import androidx.activity.result.ActivityResultCaller
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUIConstants.TUICalling.ObjectFactory.RecentCalls
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension
import com.tencent.qcloud.tuicore.interfaces.ITUINotification
import com.tencent.qcloud.tuicore.interfaces.ITUIService
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo
import com.tencent.qcloud.tuicore.interfaces.ITUIObjectFactory
import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit
import com.tencent.qcloud.tuikit.tuicallkit.TUICallKit.Companion.createInstance
import com.tencent.qcloud.tuikit.tuicallkit.extensions.recents.RecentCallsFragment
import org.json.JSONException
import org.json.JSONObject

class TUICallKitService private constructor(context: Context) : ITUINotification, ITUIService, ITUIExtension,
    ITUIObjectFactory {
    private var appContext: Context

    init {
        appContext = context
        TUICore.registerEvent(
            TUIConstants.TUILogin.EVENT_IMSDK_INIT_STATE_CHANGED,
            TUIConstants.TUILogin.EVENT_SUB_KEY_START_INIT, this
        )

        TUICore.registerService(TUIConstants.TUICalling.SERVICE_NAME, this)

        TUICore.registerExtension(TUIConstants.TUIChat.Extension.InputMore.CLASSIC_EXTENSION_ID, this)
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.InputMore.MINIMALIST_EXTENSION_ID, this)
        TUICore.registerExtension(TUIConstants.TUIGroup.Extension.GroupProfileItem.MINIMALIST_EXTENSION_ID, this)
        TUICore.registerExtension(TUIConstants.TUIGroup.Extension.GroupProfileItem.CLASSIC_EXTENSION_ID, this)
        TUICore.registerExtension(TUIConstants.TUIContact.Extension.FriendProfileItem.CLASSIC_EXTENSION_ID, this)
        TUICore.registerExtension(TUIConstants.TUIContact.Extension.FriendProfileItem.MINIMALIST_EXTENSION_ID, this)
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.CLASSIC_EXTENSION_ID, this)
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.MINIMALIST_EXTENSION_ID, this)


        TUICore.registerObjectFactory(TUIConstants.TUICalling.ObjectFactory.FACTORY_NAME, this)
    }

    override fun onNotifyEvent(key: String?, subKey: String?, param: Map<String, Any>?) {
        if (TextUtils.isEmpty(key) || TextUtils.isEmpty(subKey)) {
            return
        }
        if (TUIConstants.TUILogin.EVENT_IMSDK_INIT_STATE_CHANGED == key
            && TUIConstants.TUILogin.EVENT_SUB_KEY_START_INIT == subKey
        ) {
            TUICallKit.createInstance(appContext)
            adaptiveComponentReport()
            setExcludeFromHistoryMessage()
        }
    }

    private fun adaptiveComponentReport() {
        val service = TUICore.getService(TUIConstants.TUIChat.SERVICE_NAME)
        try {
            val params = JSONObject()
            params.put("framework", 1)
            if (service == null) {
                params.put("component", 14)
            } else {
                params.put("component", 15)
            }
            params.put("language", 2)

            val jsonObject = JSONObject()
            jsonObject.put("api", "setFramework")
            jsonObject.put("params", params)
            TUICallEngine.createInstance(appContext).callExperimentalAPI(jsonObject.toString())
        } catch (e: JSONException) {
            e.printStackTrace()
        }
    }

    private fun setExcludeFromHistoryMessage() {
        if (TUICore.getService(TUIConstants.TUIChat.SERVICE_NAME) == null) {
            return
        }
        try {
            val params = JSONObject()
            params.put("excludeFromHistoryMessage", false)
            val jsonObject = JSONObject()
            jsonObject.put("api", "setExcludeFromHistoryMessage")
            jsonObject.put("params", params)
            TUICallEngine.createInstance(appContext).callExperimentalAPI(jsonObject.toString())
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    companion object {
        private const val TAG = "TUICallKitService"
        private const val CALL_MEMBER_LIMIT = 9

        fun sharedInstance(context: Context): TUICallKitService {
            return TUICallKitService(context)
        }
    }

    override fun onGetExtension(extensionID: String?, param: Map<String?, Any?>?): List<TUIExtensionInfo?>? {
        if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.InputMore.CLASSIC_EXTENSION_ID)) {
            return getClassicChatInputMoreExtension(param)
        } else if (TextUtils.equals(
                extensionID,
                TUIConstants.TUIGroup.Extension.GroupProfileItem.MINIMALIST_EXTENSION_ID
            )
        ) {
            return getMinimalistGroupProfileExtension(param)
        } else if (TextUtils.equals(
                extensionID,
                TUIConstants.TUIContact.Extension.FriendProfileItem.CLASSIC_EXTENSION_ID
            )
        ) {
            return getClassicFriendProfileExtension(param)
        } else if (TextUtils.equals(
                extensionID,
                TUIConstants.TUIContact.Extension.FriendProfileItem.MINIMALIST_EXTENSION_ID
            )
        ) {
            return getMinimalistFriendProfileExtension(param)
        } else if (TextUtils.equals(
                extensionID,
                TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.MINIMALIST_EXTENSION_ID
            )
        ) {
            return getMinimalistChatNavigationMoreExtension(param)
        }
        return null
    }

    private fun getClassicChatInputMoreExtension(param: Map<String?, Any?>?): List<TUIExtensionInfo>? {
        val voiceCallExtension = TUIExtensionInfo()
        voiceCallExtension.weight = 600
        val videoCallExtension = TUIExtensionInfo()
        videoCallExtension.weight = 500
        val userID: String? = getOrDefault<String>(param, TUIConstants.TUIChat.Extension.InputMore.USER_ID, null)
        val groupID: String? = getOrDefault<String>(param, TUIConstants.TUIChat.Extension.InputMore.GROUP_ID, null)
        val voiceListener: ResultTUIExtensionEventListener = ResultTUIExtensionEventListener()
        voiceListener.mediaType = TUICallDefine.MediaType.Audio
        voiceListener.userID = userID
        voiceListener.groupID = groupID
        val videoListener: ResultTUIExtensionEventListener =
            ResultTUIExtensionEventListener()
        videoListener.mediaType = TUICallDefine.MediaType.Video
        videoListener.userID = userID
        videoListener.groupID = groupID
        voiceCallExtension.text = appContext.getString(R.string.tuicalling_audio_call)
        voiceCallExtension.icon = R.drawable.tuicallkit_ic_audio_call
        voiceCallExtension.extensionListener = voiceListener
        voiceListener.activityResultCaller = getOrDefault<ActivityResultCaller>(
            param,
            TUIConstants.TUIChat.Extension.InputMore.CONTEXT, null
        )
        videoCallExtension.text = appContext.getString(R.string.tuicalling_video_call)
        videoCallExtension.icon = R.drawable.tuicallkit_ic_video_call
        videoCallExtension.extensionListener = videoListener
        videoListener.activityResultCaller = getOrDefault<ActivityResultCaller>(
            param,
            TUIConstants.TUIChat.Extension.InputMore.CONTEXT, null
        )
        val filterVoice: Boolean =
            getOrDefault<Boolean>(param, TUIConstants.TUIChat.Extension.InputMore.FILTER_VOICE_CALL, false) == true
        val filterVideo: Boolean =
            getOrDefault<Boolean>(param, TUIConstants.TUIChat.Extension.InputMore.FILTER_VIDEO_CALL, false) == true
        val extensionInfoList: MutableList<TUIExtensionInfo> = ArrayList()
        if (!filterVoice) {
            extensionInfoList.add(voiceCallExtension)
        }
        if (!filterVideo) {
            extensionInfoList.add(videoCallExtension)
        }
        return extensionInfoList
    }

    inner class ResultTUIExtensionEventListener : TUIExtensionEventListener() {
        var activityResultCaller: ActivityResultCaller? = null
        var mediaType: TUICallDefine.MediaType? = null
        var isClassicUI = true
        var userID: String? = null
        var groupID: String? = null
        override fun onClicked(param: Map<String, Any>?) {
            if (!TextUtils.isEmpty(groupID)) {
                var groupMemberSelectActivityName =
                    TUIConstants.TUIContact.StartActivity.GroupMemberSelect.CLASSIC_ACTIVITY_NAME
                if (!isClassicUI) {
                    groupMemberSelectActivityName =
                        TUIConstants.TUIContact.StartActivity.GroupMemberSelect.MINIMALIST_ACTIVITY_NAME
                }
                val bundle = Bundle()
                bundle.putString(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.GROUP_ID, groupID)
                bundle.putBoolean(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.SELECT_FOR_CALL, true)
                bundle.putInt(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.MEMBER_LIMIT, CALL_MEMBER_LIMIT)
                TUICore.startActivityForResult(
                    activityResultCaller, groupMemberSelectActivityName, bundle
                ) { result: ActivityResult ->
                    val data = result.data
                    if (data != null) {
                        val stringList: ArrayList<String>? = data.getStringArrayListExtra(
                            TUIConstants.TUIContact.StartActivity.GroupMemberSelect.DATA_LIST
                        )
                        TUICallKit.createInstance(appContext).groupCall(groupID!!, stringList, mediaType!!)
                    }
                }
            } else if (!TextUtils.isEmpty(userID)) {
                TUICallKit.createInstance(appContext).call(userID!!, mediaType!!)
            } else {
                Log.e(TAG, "onClicked event ignored, groupId is empty or userId is empty, cannot start call")
            }
        }
    }

    private fun getMinimalistGroupProfileExtension(param: Map<String?, Any?>?): List<TUIExtensionInfo>? {
        val voiceCallExtension = TUIExtensionInfo()
        voiceCallExtension.weight = 200
        val videoCallExtension = TUIExtensionInfo()
        videoCallExtension.weight = 100
        val groupID = getOrDefault<String?>(param, TUIConstants.TUIGroup.Extension.GroupProfileItem.GROUP_ID, null)
        val voiceListener = ResultTUIExtensionEventListener()
        voiceListener.mediaType = TUICallDefine.MediaType.Audio
        voiceListener.groupID = groupID
        voiceListener.isClassicUI = false
        val videoListener = ResultTUIExtensionEventListener()
        videoListener.mediaType = TUICallDefine.MediaType.Video
        videoListener.groupID = groupID
        videoListener.isClassicUI = false
        voiceCallExtension.text = appContext.getString(R.string.tuicalling_audio_call)
        voiceCallExtension.icon = R.drawable.tuicallkit_profile_minimalist_audio_icon
        voiceCallExtension.extensionListener = voiceListener
        voiceListener.activityResultCaller = getOrDefault<ActivityResultCaller?>(
            param,
            TUIConstants.TUIGroup.Extension.GroupProfileItem.CONTEXT, null
        )
        voiceListener.isClassicUI = false
        videoCallExtension.text = appContext.getString(R.string.tuicalling_video_call)
        videoCallExtension.icon = R.drawable.tuicallkit_profile_minimalist_video_icon
        videoCallExtension.extensionListener = videoListener
        videoListener.isClassicUI = false
        videoListener.activityResultCaller = getOrDefault<ActivityResultCaller?>(
            param,
            TUIConstants.TUIGroup.Extension.GroupProfileItem.CONTEXT, null
        )
        val extensionInfoList: MutableList<TUIExtensionInfo> = java.util.ArrayList()
        extensionInfoList.add(videoCallExtension)
        extensionInfoList.add(voiceCallExtension)
        return extensionInfoList
    }

    private fun getClassicFriendProfileExtension(param: Map<String?, Any?>?): List<TUIExtensionInfo>? {
        val voiceCallExtension = TUIExtensionInfo()
        voiceCallExtension.weight = 300
        val videoCallExtension = TUIExtensionInfo()
        videoCallExtension.weight = 200
        val userID = getOrDefault<String?>(param, TUIConstants.TUIContact.Extension.FriendProfileItem.USER_ID, null)
        val voiceListener = ResultTUIExtensionEventListener()
        voiceListener.mediaType = TUICallDefine.MediaType.Audio
        voiceListener.userID = userID
        val videoListener = ResultTUIExtensionEventListener()
        videoListener.mediaType = TUICallDefine.MediaType.Video
        videoListener.userID = userID
        voiceCallExtension.text = appContext.getString(R.string.tuicalling_audio_call)
        voiceCallExtension.extensionListener = voiceListener
        videoCallExtension.text = appContext.getString(R.string.tuicalling_video_call)
        videoCallExtension.extensionListener = videoListener
        val extensionInfoList: MutableList<TUIExtensionInfo> = java.util.ArrayList()
        extensionInfoList.add(videoCallExtension)
        extensionInfoList.add(voiceCallExtension)
        return extensionInfoList
    }

    private fun getMinimalistFriendProfileExtension(param: Map<String?, Any?>?): List<TUIExtensionInfo>? {
        val voiceCallExtension = TUIExtensionInfo()
        voiceCallExtension.weight = 300
        val videoCallExtension = TUIExtensionInfo()
        videoCallExtension.weight = 200
        val userID = getOrDefault<String?>(param, TUIConstants.TUIContact.Extension.FriendProfileItem.USER_ID, null)
        val voiceListener = ResultTUIExtensionEventListener()
        voiceListener.mediaType = TUICallDefine.MediaType.Audio
        voiceListener.userID = userID
        voiceListener.isClassicUI = false
        val videoListener = ResultTUIExtensionEventListener()
        videoListener.mediaType = TUICallDefine.MediaType.Video
        videoListener.userID = userID
        videoListener.isClassicUI = false
        voiceCallExtension.icon = R.drawable.tuicallkit_profile_minimalist_audio_icon
        voiceCallExtension.text = appContext.getString(R.string.tuicalling_audio_call)
        voiceCallExtension.extensionListener = voiceListener
        videoCallExtension.icon = R.drawable.tuicallkit_profile_minimalist_video_icon
        videoCallExtension.text = appContext.getString(R.string.tuicalling_video_call)
        videoCallExtension.extensionListener = videoListener
        val extensionInfoList: MutableList<TUIExtensionInfo> = java.util.ArrayList()
        extensionInfoList.add(videoCallExtension)
        extensionInfoList.add(voiceCallExtension)
        return extensionInfoList
    }

    private fun getMinimalistChatNavigationMoreExtension(param: Map<String?, Any?>?): List<TUIExtensionInfo>? {
        val userID = getOrDefault<String?>(param, TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.USER_ID, null)
        val groupID = getOrDefault<String?>(param, TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.GROUP_ID, null)
        val voiceListener = ResultTUIExtensionEventListener()
        voiceListener.mediaType = TUICallDefine.MediaType.Audio
        voiceListener.groupID = groupID
        voiceListener.userID = userID
        voiceListener.isClassicUI = false
        voiceListener.activityResultCaller = getOrDefault<ActivityResultCaller?>(
            param,
            TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.CONTEXT, null
        )
        val videoListener = ResultTUIExtensionEventListener()
        videoListener.mediaType = TUICallDefine.MediaType.Video
        videoListener.groupID = groupID
        videoListener.userID = userID
        videoListener.isClassicUI = false
        videoListener.activityResultCaller = getOrDefault<ActivityResultCaller?>(
            param,
            TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.CONTEXT, null
        )
        val voiceCallExtension = TUIExtensionInfo()
        val videoCallExtension = TUIExtensionInfo()
        voiceCallExtension.icon = R.drawable.tuicallkit_chat_title_bar_minimalist_audio_call_icon
        voiceCallExtension.extensionListener = voiceListener
        videoCallExtension.icon = R.drawable.tuicallkit_chat_title_bar_minimalist_video_call_icon
        videoCallExtension.extensionListener = videoListener
        val extensionInfoList: MutableList<TUIExtensionInfo> = java.util.ArrayList()
        extensionInfoList.add(voiceCallExtension)
        extensionInfoList.add(videoCallExtension)
        return extensionInfoList
    }

    private fun <T> getOrDefault(map: Map<*, *>?, key: Any, defaultValue: T?): T? {
        if (map == null || map.isEmpty()) {
            return defaultValue
        }
        val value = map[key]
        try {
            if (value != null) {
                return value as T
            }
        } catch (e: ClassCastException) {
            return defaultValue
        }
        return defaultValue
    }

    override fun onCall(method: String?, param: Map<String?, Any?>?): Any? {
        Log.i(TAG, "onCall, method: $method ,param: $param")
        if (TextUtils.isEmpty(method)) {
            return null
        }
        if (null != param && TextUtils.equals(TUIConstants.TUICalling.METHOD_NAME_ENABLE_FLOAT_WINDOW, method)) {
            val enableFloatWindow = param[TUIConstants.TUICalling.PARAM_NAME_ENABLE_FLOAT_WINDOW] as Boolean
            Log.i(TAG, "onCall, enableFloatWindow: $enableFloatWindow")
            createInstance(appContext).enableFloatWindow(enableFloatWindow)
            return null
        }
        if (null != param && TextUtils.equals(TUIConstants.TUICalling.METHOD_NAME_ENABLE_MULTI_DEVICE, method)) {
            val enable = param[TUIConstants.TUICalling.PARAM_NAME_ENABLE_MULTI_DEVICE] as Boolean
            Log.i(TAG, "onCall, enableMultiDevice: $enable")
            TUICallEngine.createInstance(appContext)
                .enableMultiDeviceAbility(enable, object : TUICommonDefine.Callback {
                    override fun onSuccess() {}
                    override fun onError(errCode: Int, errMsg: String) {}
                })
            return null
        }
        if (null != param && TextUtils.equals(TUIConstants.TUICalling.METHOD_NAME_CALL, method)) {
            val userIDs = param[TUIConstants.TUICalling.PARAM_NAME_USERIDS] as Array<String>?
            val typeString = param[TUIConstants.TUICalling.PARAM_NAME_TYPE] as String?
            val groupID = param[TUIConstants.TUICalling.PARAM_NAME_GROUPID] as String?
            val userIdList: List<String?>? = userIDs?.toList() ?: null
            var mediaType = TUICallDefine.MediaType.Unknown
            if (TUIConstants.TUICalling.TYPE_AUDIO == typeString) {
                mediaType = TUICallDefine.MediaType.Audio
            } else if (TUIConstants.TUICalling.TYPE_VIDEO == typeString) {
                mediaType = TUICallDefine.MediaType.Video
            }
            if (!TextUtils.isEmpty(groupID)) {
                createInstance(appContext).groupCall(groupID!!, userIdList, mediaType)
            } else if (userIdList?.size == 1) {
                createInstance(appContext).call(userIdList[0]!!, mediaType)
            } else {
                Log.e(TAG, "onCall ignored, groupId is empty and userList is not 1, cannot start call or groupCall")
            }
        }
        return null
    }

    override fun onCreateObject(objectName: String?, param: MutableMap<String?, Any?>?): Any? {
        if (TextUtils.equals(objectName, RecentCalls.OBJECT_NAME)) {
            var style = RecentCalls.UI_STYLE_MINIMALIST
            if (param != null && param[RecentCalls.UI_STYLE] != null && RecentCalls.UI_STYLE_CLASSIC == param[RecentCalls.UI_STYLE]!!) {
                style = RecentCalls.UI_STYLE_CLASSIC
            }
            return RecentCallsFragment(style)
        }
        return null
    }
}