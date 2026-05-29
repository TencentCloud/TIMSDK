package com.tencent.qcloud.tuikit.tuicallkit.manager

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.imsdk.v2.V2TIMFriendInfoResult
import com.tencent.imsdk.v2.V2TIMManager
import com.tencent.imsdk.v2.V2TIMValueCallback
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import io.trtc.tuikit.atomicxcore.api.call.CallParticipantInfo

class UserManager {

    fun updateUserListInfo(userList: List<String?>?, callback: TUICommonDefine.ValueCallback<List<CallParticipantInfo>?>?) {
        getUserListInfo(userList, object : TUICommonDefine.ValueCallback<List<UserInfo>> {
            override fun onSuccess(data: List<UserInfo>) {
                val userList: MutableList<CallParticipantInfo> = ArrayList()
                for (i in data.indices) {
                    val userInfo = data[i]
                    Logger.i(TAG, "updateUserListInfo: $userInfo")
                    if (userInfo.id.isNullOrEmpty()) {
                        continue
                    }

                    val user = CallParticipantInfo()
                    user.id = userInfo.id
                    var name: String? = userInfo.id
                    if (!userInfo.remark.isNullOrEmpty()) {
                        name = userInfo.remark
                    } else if (!userInfo.nickname.isNullOrEmpty()) {
                        name = userInfo.nickname
                    }
                    if (name != null) {
                        user.name = name
                    }
                    user.avatarURL = userInfo.avatar
                    userList.add(user)
                }
                callback?.onSuccess(userList)
            }

            override fun onError(errCode: Int, errMsg: String?) {
                Logger.e(TAG, "updateUserListInfo error, errorCode: $errCode, errorMsg: $errMsg")
                callback?.onError(errCode, errMsg)
            }
        })
    }

    private fun getUserListInfo(userList: List<String?>?, callback: TUICommonDefine.ValueCallback<List<UserInfo>>?) {
        V2TIMManager.getFriendshipManager()
            .getFriendsInfo(userList, object : V2TIMValueCallback<List<V2TIMFriendInfoResult>> {
                override fun onSuccess(list: List<V2TIMFriendInfoResult>) {
                    if (list.isNullOrEmpty()) {
                        Logger.e(TAG, "getUserListInfo result is empty")
                        callback?.onError(ERROR_CODE, ERROR_MSG)
                        return
                    }

                    val userList: MutableList<UserInfo> = ArrayList()
                    for (i in list.indices) {
                        val friendInfo = list[i].friendInfo

                        val userInfo = UserInfo()
                        userInfo.id = friendInfo?.userID ?: ""
                        userInfo.remark = friendInfo?.friendRemark ?: ""
                        userInfo.nickname = friendInfo?.userProfile?.nickName ?: ""
                        userInfo.avatar = friendInfo?.userProfile?.faceUrl ?: ""
                        userList.add(userInfo)
                    }
                    callback?.onSuccess(userList)
                }

                override fun onError(errorCode: Int, errorMsg: String?) {
                    callback?.onError(errorCode, errorMsg)
                }
            })
    }

    internal class UserInfo {
        var id: String = ""
        var avatar: String = ""
        var nickname: String = ""
        var remark: String = ""

        override fun toString(): String {
            return "UserInfo{userId: $id, nickname: $nickname, avatar: $avatar, remark: $remark}"
        }
    }

    companion object {
        private const val TAG = "UserManager"
        val instance: UserManager = UserManager()
        private const val ERROR_CODE = -1
        private const val ERROR_MSG = "getUserInfo result is empty"
    }
}