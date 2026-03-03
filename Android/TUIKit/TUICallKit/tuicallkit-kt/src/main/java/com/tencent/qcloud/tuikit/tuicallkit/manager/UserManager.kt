package com.tencent.qcloud.tuikit.tuicallkit.manager

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.tencent.imsdk.v2.V2TIMFriendInfoResult
import com.tencent.imsdk.v2.V2TIMManager
import com.tencent.imsdk.v2.V2TIMValueCallback
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.state.UserState

class UserManager {
    fun updateUserInfo(user: UserState.User) {
        if (user.id.isNullOrEmpty()) {
            Logger.e(TAG, "updateUserInfo, user.userId isEmpty")
            return
        }
        val userList: MutableList<String> = ArrayList()
        userList.add(user.id)

        getUserListInfo(userList, object : TUICommonDefine.ValueCallback<List<UserInfo>> {
            override fun onSuccess(data: List<UserInfo>) {
                val userInfo = data[0]
                Logger.i(TAG, "updateUserInfo: $userInfo")
                var name = userInfo.id
                if (!userInfo.remark.isNullOrEmpty()) {
                    name = userInfo.remark
                } else if (!userInfo.nickname.isNullOrEmpty()) {
                    name = userInfo.nickname
                }
                user.nickname.set(name)
                user.avatar.set(userInfo.avatar)
            }

            override fun onError(errCode: Int, errMsg: String?) {
                Logger.e(TAG, "updateUserInfo userId:${user.id} error, errorCode: $errCode, errorMsg: $errMsg")
            }
        })
    }

    fun updateUserListInfo(userList: List<String?>?, callback: TUICommonDefine.ValueCallback<List<UserState.User>?>?) {
        getUserListInfo(userList, object : TUICommonDefine.ValueCallback<List<UserInfo>> {
            override fun onSuccess(data: List<UserInfo>) {
                val userList: MutableList<UserState.User> = ArrayList()
                for (i in data.indices) {
                    val userInfo = data[i]
                    Logger.i(TAG, "updateUserListInfo: $userInfo")
                    if (userInfo.id.isNullOrEmpty()) {
                        continue
                    }

                    val user = UserState.User()
                    user.id = userInfo.id
                    var name: String? = userInfo.id
                    if (!userInfo.remark.isNullOrEmpty()) {
                        name = userInfo.remark
                    } else if (!userInfo.nickname.isNullOrEmpty()) {
                        name = userInfo.nickname
                    }
                    user.nickname.set(name)
                    user.avatar.set(userInfo.avatar)
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

    fun getUserDisplayName(userId: String): String {
        var displayName = userId
        getUserDisplayName(userId, object : TUICommonDefine.ValueCallback<String> {
            override fun onSuccess(name: String?) {
                if (!name.isNullOrEmpty()) {
                    displayName = name
                }
            }

            override fun onError(errCode: Int, errMsg: String?) {
            }
        })
        return displayName
    }

    fun getUserDisplayName(userId: String, callback: TUICommonDefine.ValueCallback<String>) {
        var displayUser: UserState.User? = UserState.User()
        if (userId == CallManager.instance.userState.selfUser.get().id) {
            displayUser = CallManager.instance.userState.selfUser.get()
        }

        for (user in CallManager.instance.userState.remoteUserList.get()) {
            if (user.id == userId) {
                displayUser = user
                break
            }
        }

        if (!displayUser?.nickname?.get().isNullOrEmpty()) {
            callback.onSuccess(displayUser?.nickname?.get())
            return
        }
        callback.onSuccess(userId)
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