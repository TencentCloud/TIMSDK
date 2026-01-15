package com.tencent.qcloud.tuikit.tuiofficialaccountplugin.interfaces

interface IOfficialAccountListView {
    fun onSubscribedAccountsChanged()
    fun onAllAccountsChanged()
    fun onLoadFailed(code: Int, desc: String?)
    fun onSubscribeSuccess(officialAccountId: String)
    fun onSubscribeFailed(officialAccountId: String, code: Int, desc: String?)
    fun onUnsubscribeSuccess(officialAccountId: String)
    fun onUnsubscribeFailed(officialAccountId: String, code: Int, desc: String?)
    fun onLastMessageUpdated(officialAccountId: String, lastMessage: String?)
}

