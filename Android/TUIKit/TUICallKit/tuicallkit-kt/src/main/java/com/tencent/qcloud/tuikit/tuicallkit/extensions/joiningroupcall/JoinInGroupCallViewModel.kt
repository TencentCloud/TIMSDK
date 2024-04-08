package com.tencent.qcloud.tuikit.tuicallkit.extensions.joiningroupcall

import android.content.Context
import android.view.View
import android.view.ViewGroup
import com.google.gson.Gson
import com.tencent.imsdk.v2.V2TIMGroupListener
import com.tencent.imsdk.v2.V2TIMManager
import com.tencent.imsdk.v2.V2TIMValueCallback
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState

class JoinInGroupCallViewModel(context: Context) {
    private val appContext: Context
    private var parentViewGroup: ViewGroup? = null
    private var callView: JoinInGroupCallView? = null
    private var currentGroupId: String? = null

    private val groupListener: V2TIMGroupListener = object : V2TIMGroupListener() {
        override fun onGroupAttributeChanged(groupID: String?, groupAttributeMap: MutableMap<String?, String>?) {
            if (groupID.isNullOrEmpty() || currentGroupId != groupID) {
                TUILog.w(TAG, "onGroupAttributes, not same group(current:$currentGroupId, $groupID)}, ignore")
                return
            }

            parseGroupAttributes(groupID, groupAttributeMap)
        }
    }

    init {
        appContext = context.applicationContext
        V2TIMManager.getInstance().addGroupListener(groupListener)
    }

    fun setParentView(parentView: ViewGroup) {
        parentViewGroup = parentView
    }

    fun getGroupAttributes(groupId: String) {
        TUILog.i(TAG, "getGroupAttributes, groupId: $groupId")
        currentGroupId = groupId

        V2TIMManager.getGroupManager().getGroupAttributes(groupId, listOf(KEY_GROUP_ATTRIBUTE),
            object : V2TIMValueCallback<Map<String?, String?>?> {
                override fun onSuccess(map: Map<String?, String?>?) {

                    parseGroupAttributes(groupId, map)
                }

                override fun onError(code: Int, desc: String) {
                    TUILog.e(TAG, "getGroupAttributes failed, errorCode: $code , errorMsg: $desc")
                }
            })
    }

    private fun parseGroupAttributes(groupId: String, map: Map<String?, String?>?) {
        if (TUICallState.instance.selfUser.get().callStatus.get() != TUICallDefine.Status.None) {
            removeCallView()
            TUILog.w(TAG, "parseGroupAttributes, user is in the call, ignore")
            return
        }

        if (map == null || map[KEY_GROUP_ATTRIBUTE].isNullOrEmpty()) {
            TUILog.w(TAG, "parseGroupAttributes is empty, map: $map")
            removeCallView()
            return
        }

        TUILog.i(TAG, "parseGroupAttributes, groupId: $groupId, map: $map")

        val data: String? = map[KEY_GROUP_ATTRIBUTE]
        val extraMap: Map<String, Any> = Gson().fromJson<Map<String, Any>>(data, Map::class.java)

        val businessType = extraMap[KEY_BUSINESS_TYPE] as? String
        if (businessType.isNullOrEmpty() || businessType != VALUE_BUSINESS_TYPE) {
            removeCallView()
            return
        }

        val userList = parseUserList(extraMap)
        if (userList.isEmpty() || userList.contains(TUILogin.getLoginUser())) {
            TUILog.w(TAG, "userList: $userList, loginUser:${TUILogin.getLoginUser()}")
            removeCallView()
            return
        }
        val groupId = extraMap[KEY_GROUP_ID] as? String
        val roomId = parseRoomId(extraMap)

        val mediaType = if (extraMap[KEY_CALL_MEDIA_TYPE] == VALUE_MEDIA_TYPE_VIDEO) {
            TUICallDefine.MediaType.Video
        } else {
            TUICallDefine.MediaType.Audio
        }

        if (callView == null) {
            callView = JoinInGroupCallView(appContext)
        }
        TUILog.i(TAG, "groupId: $groupId, roomId:$roomId, mediaType: $mediaType, userList: $userList")
        callView?.updateView(groupId, roomId, mediaType, userList)
        showCallView()
    }

    private fun parseRoomId(extraMap: Map<String, Any>): TUICommonDefine.RoomId {
        val roomIdType = (extraMap[KEY_ROOM_ID_TYPE] as? Double)?.toInt()
        val strRoomId = extraMap[KEY_ROOM_ID] as? String

        val roomId = TUICommonDefine.RoomId()
        if (roomIdType == VALUE_ROOM_ID_TYPE_STRING) {
            roomId.strRoomId = strRoomId
            return roomId
        }

        val intRoomId = strRoomId?.toIntOrNull()
        if (intRoomId != null && intRoomId != 0) {
            roomId.intRoomId = intRoomId
        } else {
            roomId.strRoomId = strRoomId
        }
        return roomId
    }

    private fun parseUserList(extraMap: Map<String, Any>): List<String> {
        val userIds = extraMap[KEY_USER_LIST] as? List<Map<String, String>>
        if (userIds == null) {
            TUILog.w(TAG, "parseUserList, userList is empty, ignore")
            return ArrayList<String>()
        }
        val list = ArrayList<String>()

        for (temp in userIds) {
            val userId = temp[KEY_USER_ID]
            if (userId != null) {
                list.add(userId)
            }
        }
        return list
    }

    private fun showCallView() {
        if (callView?.parent != null) {
            (callView?.parent as ViewGroup).removeView(callView)
        }
        if (callView != null) {
            parentViewGroup?.addView(callView)
            parentViewGroup?.visibility = View.VISIBLE
        }
    }

    private fun removeCallView() {
        if (callView?.parent != null) {
            (callView?.parent as ViewGroup).removeView(callView)
        }
    }

    companion object {
        private const val TAG = "JoinInGroupCall"

        //Do not change these items
        private const val KEY_GROUP_ATTRIBUTE = "inner_attr_kit_info"
        private const val KEY_BUSINESS_TYPE = "business_type"
        private const val KEY_ROOM_ID_TYPE = "room_id_type"
        private const val KEY_ROOM_ID = "room_id"
        private const val KEY_GROUP_ID = "group_id"
        private const val KEY_CALL_MEDIA_TYPE = "call_media_type"
        private const val KEY_USER_LIST = "user_list"
        private const val KEY_USER_ID = "userid"

        private const val VALUE_BUSINESS_TYPE = "callkit"
        private const val VALUE_MEDIA_TYPE_AUDIO = "audio"
        private const val VALUE_MEDIA_TYPE_VIDEO = "video"
        private const val VALUE_ROOM_ID_TYPE_HISTORY = 0
        private const val VALUE_ROOM_ID_TYPE_INT = 1
        private const val VALUE_ROOM_ID_TYPE_STRING = 2
    }
}
