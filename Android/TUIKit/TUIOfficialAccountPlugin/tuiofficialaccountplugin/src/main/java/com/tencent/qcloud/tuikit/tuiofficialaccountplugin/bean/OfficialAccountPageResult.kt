package com.tencent.qcloud.tuikit.tuiofficialaccountplugin.bean


data class OfficialAccountPageResult(
    val officialAccounts: List<OfficialAccountInfo>,
    val totalCount: Int,
    val nextOffset: Long,
    val hasMore: Boolean
)