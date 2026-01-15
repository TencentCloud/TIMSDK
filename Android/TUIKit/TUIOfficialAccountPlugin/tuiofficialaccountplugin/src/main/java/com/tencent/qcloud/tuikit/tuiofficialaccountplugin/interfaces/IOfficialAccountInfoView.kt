package com.tencent.qcloud.tuikit.tuiofficialaccountplugin.interfaces

import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.bean.OfficialAccountInfo

interface IOfficialAccountInfoView {
    fun onOfficialAccountInfoLoaded(info: OfficialAccountInfo)
    fun onLoadFailed(code: Int, desc: String?)
    fun onSubscriptionStatusChanged(isSubscribed: Boolean)
    fun onSubscriptionFailed(code: Int, desc: String?)
}

