package com.tencent.qcloud.tuikit.tuiofficialaccountplugin.bean

import java.io.Serializable

data class OfficialAccountInfo(
    val officialAccount: String,

    val ownerAccount: String,

    var name: String,

    var introduction: String,

    var faceUrl: String,

    var maxSubscriberNum: Long = 100000,

    val subscriberNum: Long,

    val createTime: Long,

    var organization: String,

    var customString: String
) : Serializable