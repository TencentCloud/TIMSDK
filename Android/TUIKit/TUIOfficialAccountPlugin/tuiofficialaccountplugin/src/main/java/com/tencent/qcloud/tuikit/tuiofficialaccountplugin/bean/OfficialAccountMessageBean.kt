package com.tencent.qcloud.tuikit.tuiofficialaccountplugin.bean

import com.tencent.imsdk.v2.V2TIMMessage
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean
import com.tencent.qcloud.tuikit.timcommon.util.TextUtil
import com.tencent.qcloud.tuikit.tuichat.TUIChatService
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.TUIOfficialAccountService
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.util.OfficialAccountMessageParser

class OfficialAccountMessageBean : TUIMessageBean() {

    var officialAccountMessage: OfficialAccountMessage? = null
        private set

    override fun onProcessMessage(v2TIMMessage: V2TIMMessage) {
        officialAccountMessage = OfficialAccountMessageParser.parseOfficialAccountMessage(v2TIMMessage)
        if (officialAccountMessage != null) {
            if (!officialAccountMessage?.content.isNullOrEmpty()) {
                setExtra(TextUtil.processMarkdownLinks(officialAccountMessage?.content).toString())
            } else if (officialAccountMessage?.imageInfo != null) {
                setExtra(TUIChatService.getAppContext()
                    .getString(com.tencent.qcloud.tuikit.tuichat.R.string.picture_extra))
            }
        }
    }

    override fun onGetDisplayString(): String {
        return extra
    }

    override fun isEnableForward(): Boolean {
        return true
    }

}
