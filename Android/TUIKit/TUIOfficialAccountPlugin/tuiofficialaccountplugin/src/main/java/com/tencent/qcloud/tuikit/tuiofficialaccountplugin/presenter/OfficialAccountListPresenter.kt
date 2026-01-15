package com.tencent.qcloud.tuikit.tuiofficialaccountplugin.presenter

import com.tencent.imsdk.v2.V2TIMConversation
import com.tencent.imsdk.v2.V2TIMConversationListener
import com.tencent.imsdk.v2.V2TIMFriendshipListener
import com.tencent.imsdk.v2.V2TIMManager
import com.tencent.imsdk.v2.V2TIMOfficialAccountInfo
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.interfaces.TUICallback
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.bean.OfficialAccountInfo
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.bean.OfficialAccountPageResult
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.interfaces.IOfficialAccountListView
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.model.OfficialAccountProvider
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.util.TUIOfficialAccountLog

class OfficialAccountListPresenter {
    companion object {
        private const val TAG = "OfficialAccountListPresenter"
        private const val PAGE_SIZE = 20
    }

    private var view: IOfficialAccountListView? = null
    private val provider: OfficialAccountProvider = OfficialAccountProvider()
    private var currentUserId: String? = null
    private var nextOffset: Long = 0L
    private var isLoading: Boolean = false
    private var hasMore: Boolean = true
    
    private val subscribedAccountsList = mutableListOf<OfficialAccountInfo>()
    private val createdAccountsList = mutableListOf<OfficialAccountInfo>()
    private val allAccountsList = mutableListOf<OfficialAccountInfo>()
    
    private val subscribedAccountIds = mutableSetOf<String>()
    private val lastMessagesCache = mutableMapOf<String, String?>()
    
    private val conversationListener = object : V2TIMConversationListener() {
        override fun onConversationChanged(conversationList: MutableList<V2TIMConversation>?) {
            conversationList?.forEach { conversation ->
                if (conversation.conversationID.startsWith("c2c_")) {
                    val officialAccountId = conversation.conversationID.removePrefix("c2c_")
                    
                    if (subscribedAccountIds.contains(officialAccountId)) {
                        val lastMessage = ChatMessageParser.getDisplayString(conversation.lastMessage)
                        lastMessagesCache[officialAccountId] = lastMessage
                        
                        TUIOfficialAccountLog.i(TAG, "Conversation updated for: $officialAccountId, message: $lastMessage")
                        view?.onLastMessageUpdated(officialAccountId, lastMessage)
                    }
                }
            }
        }
    }

    private val officialAccountListener = object : V2TIMFriendshipListener() {
        override fun onOfficialAccountDeleted(officialAccountID: String?) {
            officialAccountID?.let { accountId ->
                TUIOfficialAccountLog.i(TAG, "onOfficialAccountDeleted: $accountId")
                handleOfficialAccountRemoval(accountId)
                
                subscribedAccountsList.removeAll { it.officialAccount == accountId }
                createdAccountsList.removeAll { it.officialAccount == accountId }
                allAccountsList.removeAll { it.officialAccount == accountId }
                
                view?.onSubscribedAccountsChanged()
                view?.onAllAccountsChanged()
            }
        }

        override fun onOfficialAccountInfoChanged(officialAccountInfo: V2TIMOfficialAccountInfo?) {
            officialAccountInfo?.let { info ->
                TUIOfficialAccountLog.i(TAG, "onOfficialAccountInfoChanged: ${info.officialAccountID}")
                
                provider.loadOfficialAccountInfo(info.officialAccountID, object : TUIValueCallback<OfficialAccountInfo>() {
                    override fun onSuccess(accountInfo: OfficialAccountInfo) {
                        updateAccountInCache(accountInfo)
                        
                        if (subscribedAccountIds.contains(accountInfo.officialAccount)) {
                            view?.onSubscribedAccountsChanged()
                        } else {
                            view?.onAllAccountsChanged()
                        }
                    }
                    
                    override fun onError(errorCode: Int, errorMessage: String?) {
                        TUIOfficialAccountLog.e(TAG, "Failed to get account info: $errorCode, $errorMessage")
                    }
                })
            }
        }

        override fun onOfficialAccountSubscribed(officialAccountInfo: V2TIMOfficialAccountInfo?) {
            officialAccountInfo?.let { info ->
                TUIOfficialAccountLog.i(TAG, "onOfficialAccountSubscribed: ${info.officialAccountID}")
                subscribedAccountIds.add(info.officialAccountID)
                
                provider.loadOfficialAccountInfo(info.officialAccountID, object : TUIValueCallback<OfficialAccountInfo>() {
                    override fun onSuccess(accountInfo: OfficialAccountInfo) {
                        allAccountsList.removeAll { it.officialAccount == accountInfo.officialAccount }
                        
                        if (subscribedAccountsList.none { it.officialAccount == accountInfo.officialAccount }) {
                            subscribedAccountsList.add(0, accountInfo)
                        }
                        view?.onSubscribedAccountsChanged()
                        view?.onAllAccountsChanged()

                        loadLastMessagesForAccounts(listOf(accountInfo)) { 
                            view?.onSubscribedAccountsChanged()
                        }
                    }
                    
                    override fun onError(errorCode: Int, errorMessage: String?) {
                        TUIOfficialAccountLog.e(TAG, "Failed to get account info: $errorCode, $errorMessage")
                    }
                })
            }
        }

        override fun onOfficialAccountUnsubscribed(officialAccountID: String?) {
            officialAccountID?.let { accountId ->
                TUIOfficialAccountLog.i(TAG, "onOfficialAccountUnsubscribed: $accountId")
                handleOfficialAccountRemoval(accountId)
                
                val unsubscribedAccount = subscribedAccountsList.find { it.officialAccount == accountId }
                subscribedAccountsList.removeAll { it.officialAccount == accountId }
                
                unsubscribedAccount?.let { account ->
                    if (allAccountsList.none { it.officialAccount == accountId }) {
                        allAccountsList.add(0, account)
                    }
                }
                
                view?.onSubscribedAccountsChanged()
                view?.onAllAccountsChanged()
            }
        }
    }

    init {
        currentUserId = TUILogin.getUserId()
        V2TIMManager.getConversationManager().addConversationListener(conversationListener)
        V2TIMManager.getFriendshipManager().addFriendListener(officialAccountListener)
    }

    fun setView(view: IOfficialAccountListView) {
        this.view = view
    }

    fun loadSubscribedOfficialAccounts() {
        provider.loadSubscribedOfficialAccounts(object : TUIValueCallback<List<OfficialAccountInfo>>() {
            override fun onSuccess(accounts: List<OfficialAccountInfo>) {
                subscribedAccountsList.clear()
                subscribedAccountsList.addAll(accounts)
                
                subscribedAccountIds.clear()
                accounts.forEach { subscribedAccountIds.add(it.officialAccount) }
                view?.onSubscribedAccountsChanged()
                loadLastMessagesForAccounts(accounts) { 
                    view?.onSubscribedAccountsChanged()
                }
            }

            override fun onError(errorCode: Int, errorMessage: String?) {
                view?.onLoadFailed(errorCode, errorMessage)
            }
        })
    }
    
    private fun loadLastMessagesForAccounts(
        accounts: List<OfficialAccountInfo>,
        callback: (List<OfficialAccountInfo>) -> Unit
    ) {
        if (accounts.isEmpty()) {
            callback(emptyList())
            return
        }
        
        val accountIds = accounts.map { it.officialAccount }
        provider.getConversationLastMessages(accountIds, object : TUIValueCallback<Map<String, String?>>() {
            override fun onSuccess(messagesMap: Map<String, String?>) {
                lastMessagesCache.putAll(messagesMap)
                callback(accounts)
            }
            
            override fun onError(errorCode: Int, errorMessage: String?) {
                accounts.forEach { account ->
                    lastMessagesCache[account.officialAccount] = null
                }
                callback(accounts)
            }
        })
    }
    
    fun getLastMessageForAccount(officialAccountId: String): String? {
        return lastMessagesCache[officialAccountId]
    }

    fun loadOfficialAccounts() {
        if (isLoading) {
            return
        }
        
        isLoading = true
        nextOffset = 0L
        hasMore = true
        allAccountsList.clear()
        
        provider.loadOfficialAccounts(PAGE_SIZE, nextOffset, object : TUIValueCallback<OfficialAccountPageResult>() {
            override fun onSuccess(pageResult: OfficialAccountPageResult) {
                isLoading = false
                nextOffset = pageResult.nextOffset
                hasMore = pageResult.hasMore
                
                allAccountsList.addAll(pageResult.officialAccounts)
                
                view?.onAllAccountsChanged()
            }

            override fun onError(errorCode: Int, errorMessage: String?) {
                isLoading = false
                view?.onLoadFailed(errorCode, errorMessage)
            }
        })
    }
    
    fun loadMoreOfficialAccounts() {
        if (isLoading || !hasMore) {
            return
        }
        
        isLoading = true
        
        provider.loadOfficialAccounts(PAGE_SIZE, nextOffset, object : TUIValueCallback<OfficialAccountPageResult>() {
            override fun onSuccess(pageResult: OfficialAccountPageResult) {
                isLoading = false
                nextOffset = pageResult.nextOffset
                hasMore = pageResult.hasMore
                
                pageResult.officialAccounts.forEach { newAccount ->
                    if (allAccountsList.none { it.officialAccount == newAccount.officialAccount }) {
                        allAccountsList.add(newAccount)
                    }
                }
                
                view?.onAllAccountsChanged()
            }

            override fun onError(errorCode: Int, errorMessage: String?) {
                isLoading = false
                view?.onLoadFailed(errorCode, errorMessage)
            }
        })
    }

    fun subscribeOfficialAccount(officialAccountId: String) {
        provider.subscribeOfficialAccount(officialAccountId, object : TUICallback() {
            override fun onSuccess() {
                subscribedAccountIds.add(officialAccountId)
                
                val accountToMove = allAccountsList.find { it.officialAccount == officialAccountId }
                if (accountToMove != null) {
                    allAccountsList.remove(accountToMove)
                    if (subscribedAccountsList.none { it.officialAccount == officialAccountId }) {
                        subscribedAccountsList.add(0, accountToMove)
                    }
                }
                
                provider.getConversationLastMessages(
                    listOf(officialAccountId),
                    object : TUIValueCallback<Map<String, String?>>() {
                        override fun onSuccess(messagesMap: Map<String, String?>) {
                            lastMessagesCache.putAll(messagesMap)
                            view?.onSubscribeSuccess(officialAccountId)
                        }
                        
                        override fun onError(errorCode: Int, errorMessage: String?) {
                            lastMessagesCache[officialAccountId] = null
                            view?.onSubscribeSuccess(officialAccountId)
                        }
                    })
            }

            override fun onError(errorCode: Int, errorMessage: String?) {
                view?.onSubscribeFailed(officialAccountId, errorCode, errorMessage)
            }
        })
    }

    fun unsubscribeOfficialAccount(officialAccountId: String) {
        provider.unsubscribeOfficialAccount(officialAccountId, object : TUICallback() {
            override fun onSuccess() {
                subscribedAccountIds.remove(officialAccountId)
                
                val accountToMove = subscribedAccountsList.find { it.officialAccount == officialAccountId }
                if (accountToMove != null) {
                    subscribedAccountsList.remove(accountToMove)
                    if (allAccountsList.none { it.officialAccount == officialAccountId }) {
                        allAccountsList.add(0, accountToMove)
                    }
                }
                
                view?.onUnsubscribeSuccess(officialAccountId)
            }

            override fun onError(errorCode: Int, errorMessage: String?) {
                view?.onUnsubscribeFailed(officialAccountId, errorCode, errorMessage)
            }
        })
    }

    fun getCurrentUserId(): String? {
        return currentUserId
    }
    
    fun isLoadingData(): Boolean {
        return isLoading
    }
    
    fun hasMoreData(): Boolean {
        return hasMore
    }

    private fun handleOfficialAccountRemoval(officialAccountId: String) {
        subscribedAccountIds.remove(officialAccountId)
        lastMessagesCache.remove(officialAccountId)
    }
    
    private fun updateAccountInCache(accountInfo: OfficialAccountInfo) {
        val subscribedIndex = subscribedAccountsList.indexOfFirst { it.officialAccount == accountInfo.officialAccount }
        if (subscribedIndex != -1) {
            subscribedAccountsList[subscribedIndex] = accountInfo
        }
        
        val createdIndex = createdAccountsList.indexOfFirst { it.officialAccount == accountInfo.officialAccount }
        if (createdIndex != -1) {
            createdAccountsList[createdIndex] = accountInfo
        }
        
        val allIndex = allAccountsList.indexOfFirst { it.officialAccount == accountInfo.officialAccount }
        if (allIndex != -1) {
            allAccountsList[allIndex] = accountInfo
        }
    }

    fun getSubscribedAccountsList(): List<OfficialAccountInfo> {
        return subscribedAccountsList.toList()
    }

    fun getCreatedAccountsList(): List<OfficialAccountInfo> {
        return createdAccountsList.toList()
    }

    fun getAllAccountsList(): List<OfficialAccountInfo> {
        return allAccountsList.filter { !subscribedAccountIds.contains(it.officialAccount) }
    }

    fun onDestroy() {
        V2TIMManager.getConversationManager().removeConversationListener(conversationListener)
        V2TIMManager.getFriendshipManager().removeFriendListener(officialAccountListener)
        view = null
    }
}

