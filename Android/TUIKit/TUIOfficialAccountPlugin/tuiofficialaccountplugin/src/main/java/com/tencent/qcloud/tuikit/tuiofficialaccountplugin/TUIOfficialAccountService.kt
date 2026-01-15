package com.tencent.qcloud.tuikit.tuiofficialaccountplugin

import android.content.Context
import android.content.Intent
import android.text.TextUtils
import com.tencent.imsdk.v2.V2TIMFriendshipListener
import com.tencent.imsdk.v2.V2TIMManager
import com.tencent.imsdk.v2.V2TIMOfficialAccountInfo
import com.tencent.qcloud.tuicore.ServiceInitializer
import com.tencent.qcloud.tuicore.TUIConstants
import com.tencent.qcloud.tuicore.TUICore
import com.tencent.qcloud.tuicore.TUIThemeManager
import com.tencent.qcloud.tuicore.annotations.TUIInitializerDependency
import com.tencent.qcloud.tuicore.annotations.TUIInitializerID
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension
import com.tencent.qcloud.tuicore.interfaces.ITUINotification
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo
import com.tencent.qcloud.tuicore.interfaces.TUIInitializer
import com.tencent.qcloud.tuicore.interfaces.ITUIService
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.bean.OfficialAccountMessageBean
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.minimalistui.OfficialAccountListActivity
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.minimalistui.OfficialAccountMessageHolder
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.util.TUIOfficialAccountLog.i
import kotlin.collections.MutableList
import kotlin.collections.MutableMap

@TUIInitializerDependency("TUIChatMinimalist")
@TUIInitializerID("TUIOfficialAccountPluginService")
class TUIOfficialAccountService : TUIInitializer, ITUINotification, ITUIExtension, ITUIService {
    private var appContext: Context? = null

    override fun init(context: Context) {
        appContext = context
        instance = this
        initTheme()
        initEvent()
        initExtension()
        initService()
        initIMListener()
        initMessage()
    }

    private fun initMessage() {
        val param: MutableMap<String?, Any?> = mutableMapOf()
        param[TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BUSINESS_ID] = TUIOfficialAccountConstants.BUSINESS_ID_OFFICIAL_ACCOUNT
        param[TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_BEAN_CLASS] = OfficialAccountMessageBean::class.java
        param[TUIConstants.TUIChat.Method.RegisterCustomMessage.MESSAGE_VIEW_HOLDER_CLASS] = OfficialAccountMessageHolder::class.java
        param[TUIConstants.TUIChat.Method.RegisterCustomMessage.IS_NEED_EMPTY_VIEW_GROUP] = true
        TUICore.callService(
            TUIConstants.TUIChat.Method.RegisterCustomMessage.MINIMALIST_SERVICE_NAME,
            TUIConstants.TUIChat.Method.RegisterCustomMessage.METHOD_NAME,
            param
        )
    }

    private fun initExtension() {
        TUICore.registerExtension(TUIConstants.TUIContact.Extension.ContactItem.MINIMALIST_EXTENSION_ID, this)
    }

    private fun initService() {
        TUICore.registerService(TUIOfficialAccountConstants.SERVICE_NAME, this)
    }

    private fun initEvent() {
        TUICore.registerEvent(
            TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED,
            TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS,
            this
        )
        TUICore.registerEvent(
            TUIConstants.TUIChat.EVENT_KEY_MESSAGE_EVENT,
            TUIConstants.TUIChat.EVENT_SUB_KEY_SEND_MESSAGE_SUCCESS,
            this
        )
        TUICore.registerEvent(
            TUIConstants.TUIChat.EVENT_KEY_MESSAGE_EVENT,
            TUIConstants.TUIChat.EVENT_SUB_KEY_SEND_MESSAGE_FAILED,
            this
        )
        TUICore.registerEvent(
            TUIConstants.TUIPollPlugin.EVENT_KEY_POLL_EVENT,
            TUIConstants.TUIPollPlugin.EVENT_SUB_KEY_POLL_VOTE_CHANGED,
            this
        )
    }

    override fun onNotifyEvent(key: String?, subKey: String?, param: MutableMap<String?, Any?>?) {
        if (TextUtils.equals(key, TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED)) {
            if (TextUtils.equals(subKey, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS)) {
                i(TAG, "TUIPoll version:" + TUIOfficialAccountConstants.OFFICIAL_ACCOUNT_PLUGIN_VERSION)
            }
        }
    }

    private fun initIMListener() {
        V2TIMManager.getFriendshipManager().addFriendListener(object : V2TIMFriendshipListener() {
            override fun onOfficialAccountSubscribed( officialAccountInfo:V2TIMOfficialAccountInfo) {
            }
            override fun onOfficialAccountDeleted(officialAccountID:String ) {
            }
            override fun onOfficialAccountInfoChanged( officialAccountInfo:V2TIMOfficialAccountInfo) {
            }
        })
    }

    private fun initTheme() {
        TUIThemeManager.addLightTheme(R.style.TUIOfficialAccountLightTheme)
        TUIThemeManager.addLivelyTheme(R.style.TUIOfficialAccountLivelyTheme)
        TUIThemeManager.addSeriousTheme(R.style.TUIOfficialAccountSeriousTheme)
    }

    override fun onGetExtension(
        extensionID: String?,
        param: MutableMap<String?, Any?>?
    ): MutableList<TUIExtensionInfo?>? {
        if (TextUtils.equals(extensionID, TUIConstants.TUIContact.Extension.ContactItem.MINIMALIST_EXTENSION_ID)) {
            val extensionInfo = TUIExtensionInfo()
            extensionInfo.weight = 300
            extensionInfo.text = appContext?.getString(R.string.official_account_official_channel)
            extensionInfo.setIcon(R.drawable.official_account_default_avatar)
            extensionInfo.extensionListener = object : TUIExtensionEventListener() {
                override fun onClicked(param: MutableMap<String?, Any?>?) {
                    val intent = Intent(getAppContext(), OfficialAccountListActivity::class.java)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    getAppContext()?.startActivity(intent)
                }
            }
            return mutableListOf(extensionInfo)
        }
        return null
    }

    companion object {
        val TAG: String = TUIOfficialAccountService::class.java.getSimpleName()
        var instance: TUIOfficialAccountService? = null
            private set

        fun getAppContext(): Context? {
            return ServiceInitializer.getAppContext()
        }
    }
}