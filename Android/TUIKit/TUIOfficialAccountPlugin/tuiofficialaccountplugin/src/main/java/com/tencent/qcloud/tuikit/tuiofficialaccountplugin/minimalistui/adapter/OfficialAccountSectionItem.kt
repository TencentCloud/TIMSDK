package com.tencent.qcloud.tuikit.tuiofficialaccountplugin.minimalistui.adapter

import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.bean.OfficialAccountInfo

sealed class OfficialAccountSectionItem {
    data class SectionHeader(val title: String) : OfficialAccountSectionItem()
    
    data class AccountItem(
        val accountInfo: OfficialAccountInfo,
        val isFollowing: Boolean,
        val lastMessage: String? = null
    ) : OfficialAccountSectionItem()
    
    data class RecommendationItem(
        val accountInfo: OfficialAccountInfo
    ) : OfficialAccountSectionItem()
}
