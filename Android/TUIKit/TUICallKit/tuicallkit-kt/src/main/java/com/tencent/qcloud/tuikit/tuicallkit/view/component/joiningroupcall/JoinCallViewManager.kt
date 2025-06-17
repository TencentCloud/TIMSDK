package com.tencent.qcloud.tuikit.tuicallkit.view.component.joiningroupcall

import android.view.View
import com.google.gson.Gson
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.imsdk.v2.V2TIMGroupListener
import com.tencent.imsdk.v2.V2TIMManager
import com.tencent.imsdk.v2.V2TIMValueCallback
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.trtc.tuikit.common.livedata.Observer

class JoinCallViewManager() {
    private var callView: JoinCallView? = null
    private var currentGroupId: String? = null

    private var callStatusObserver = Observer<TUICallDefine.Status> {
        if (it == TUICallDefine.Status.None) {
            currentGroupId?.let { it1 -> getGroupAttributes(it1) }
        }
    }

    private val groupListener: V2TIMGroupListener = object : V2TIMGroupListener() {
        override fun onGroupAttributeChanged(groupID: String?, groupAttributeMap: MutableMap<String?, String>?) {
            if (groupID.isNullOrEmpty() || currentGroupId != groupID) {
                Logger.w(TAG, "onGroupAttributes, not same group(current:$currentGroupId, $groupID)}, ignore")
                return
            }

            parseGroupAttributes(groupID, groupAttributeMap)
        }
    }

    init {
        V2TIMManager.getInstance().addGroupListener(groupListener)
        CallManager.instance.userState.selfUser.get().callStatus.observe(callStatusObserver)
    }

    fun setJoinCallView(joinCallView: JoinCallView) {
        callView = joinCallView
        callView?.visibility = View.GONE
    }

    fun getGroupAttributes(groupId: String) {
        Logger.i(TAG, "getGroupAttributes, groupId: $groupId")
        currentGroupId = groupId

        V2TIMManager.getGroupManager().getGroupAttributes(groupId, listOf(KEY_GROUP_ATTRIBUTE),
            object : V2TIMValueCallback<Map<String?, String?>?> {
                override fun onSuccess(map: Map<String?, String?>?) {

                    parseGroupAttributes(groupId, map)
                }

                override fun onError(code: Int, desc: String) {
                    Logger.e(TAG, "getGroupAttributes failed, errorCode: $code , errorMsg: $desc")
                }
            })
    }

    private fun parseGroupAttributes(groupId: String, map: Map<String?, String?>?) {
        if (CallManager.instance.userState.selfUser.get().callStatus.get() != TUICallDefine.Status.None) {
            removeCallView()
            Logger.w(TAG, "parseGroupAttributes, user is in the call, ignore")
            return
        }

        if (map == null || map[KEY_GROUP_ATTRIBUTE].isNullOrEmpty()) {
            Logger.w(TAG, "parseGroupAttributes is empty, map: $map")
            removeCallView()
            return
        }

        Logger.i(TAG, "parseGroupAttributes, groupId: $groupId, map: $map")

        val data: String? = map[KEY_GROUP_ATTRIBUTE]
        val extraMap: Map<String, Any> = Gson().fromJson<Map<String, Any>>(data, Map::class.java)

        val businessType = extraMap[KEY_BUSINESS_TYPE] as? String
        if (businessType.isNullOrEmpty() || businessType != VALUE_BUSINESS_TYPE) {
            Logger.w(TAG, "this is not callkit, ignore")
            removeCallView()
            return
        }
        val userList = parseUserList(extraMap)
        if (userList.isEmpty() || userList.contains(TUILogin.getLoginUser()) || userList.size <= 1) {
            Logger.w(TAG, "userList is empty or current user is in the call, ignore")
            removeCallView()
            return
        }

        val callId = extraMap[KEY_CALL_ID] as? String
        if (!callId.isNullOrEmpty()) {
            callView?.updateView(TUICallDefine.MediaType.Audio, userList, callId = callId)
            callView?.visibility = View.VISIBLE
            return
        }

        var mediaType = TUICallDefine.MediaType.Audio
        if (extraMap[KEY_CALL_MEDIA_TYPE] == VALUE_MEDIA_TYPE_VIDEO) {
            mediaType = TUICallDefine.MediaType.Video
        }

        val roomId = parseRoomId(extraMap)
        callView?.updateView(mediaType, userList, groupId = groupId, roomId = roomId)
        callView?.visibility = View.VISIBLE
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
            Logger.w(TAG, "parseUserList, userList is empty, ignore")
            return ArrayList()
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

    private fun removeCallView() {
        callView?.visibility = View.GONE
    }

    companion object {
        private const val TAG = "JoinCallViewManager"

        //Do not change these items
        private const val KEY_GROUP_ATTRIBUTE = "inner_attr_kit_info"
        private const val KEY_BUSINESS_TYPE = "business_type"
        private const val KEY_ROOM_ID_TYPE = "room_id_type"
        private const val KEY_CALL_ID = "call_id"
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
