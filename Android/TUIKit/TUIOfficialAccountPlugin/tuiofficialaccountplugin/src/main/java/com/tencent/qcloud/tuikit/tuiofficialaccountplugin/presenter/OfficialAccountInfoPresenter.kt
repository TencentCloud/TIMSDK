package com.tencent.qcloud.tuikit.tuiofficialaccountplugin.presenter

import com.tencent.qcloud.tuicore.interfaces.TUICallback
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.bean.OfficialAccountInfo
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.interfaces.IOfficialAccountInfoView
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.model.OfficialAccountProvider

class OfficialAccountInfoPresenter {
    companion object {
        private const val TAG = "OfficialAccountInfoPresenter"
    }

    private var view: IOfficialAccountInfoView? = null
    private val provider: OfficialAccountProvider = OfficialAccountProvider()
    private var currentOfficialAccountInfo: OfficialAccountInfo? = null
    private var isSubscribed: Boolean = false

    fun setView(view: IOfficialAccountInfoView) {
        this.view = view
    }

    fun loadOfficialAccountInfo(officialAccountId: String) {
        provider.loadOfficialAccountInfo(officialAccountId, object : TUIValueCallback<OfficialAccountInfo>() {
            override fun onSuccess(info: OfficialAccountInfo) {
                currentOfficialAccountInfo = info
                view?.onOfficialAccountInfoLoaded(info)
                checkSubscriptionStatus(officialAccountId)
            }

            override fun onError(errorCode: Int, errorMessage: String?) {
                view?.onLoadFailed(errorCode, errorMessage)
            }
        })
    }

    private fun checkSubscriptionStatus(officialAccountId: String) {
        provider.checkSubscriptionStatus(officialAccountId, object : TUIValueCallback<Boolean>() {
            override fun onSuccess(subscribed: Boolean) {
                isSubscribed = subscribed
                view?.onSubscriptionStatusChanged(subscribed)
            }

            override fun onError(errorCode: Int, errorMessage: String?) {
                view?.onSubscriptionFailed(errorCode, errorMessage)
            }
        })
    }

    fun subscribeOfficialAccount(officialAccountId: String) {
        provider.subscribeOfficialAccount(officialAccountId, object : TUICallback() {
            override fun onSuccess() {
                isSubscribed = true
                view?.onSubscriptionStatusChanged(true)
            }

            override fun onError(errorCode: Int, errorMessage: String?) {
                view?.onSubscriptionFailed(errorCode, errorMessage)
            }
        })
    }

    fun unsubscribeOfficialAccount(officialAccountId: String) {
        provider.unsubscribeOfficialAccount(officialAccountId, object : TUICallback() {
            override fun onSuccess() {
                isSubscribed = false
                view?.onSubscriptionStatusChanged(false)
            }

            override fun onError(errorCode: Int, errorMessage: String?) {
                view?.onSubscriptionFailed(errorCode, errorMessage)
            }
        })
    }

    fun isCurrentlySubscribed(): Boolean {
        return isSubscribed
    }

    fun getCurrentOfficialAccountInfo(): OfficialAccountInfo? {
        return currentOfficialAccountInfo
    }

    fun onDestroy() {
        view = null
    }
}

