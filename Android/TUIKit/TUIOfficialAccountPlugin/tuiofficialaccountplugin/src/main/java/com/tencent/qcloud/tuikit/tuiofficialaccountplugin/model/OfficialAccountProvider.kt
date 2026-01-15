package com.tencent.qcloud.tuikit.tuiofficialaccountplugin.model

import com.tencent.imsdk.v2.V2TIMCallback
import com.tencent.imsdk.v2.V2TIMConversation
import com.tencent.imsdk.v2.V2TIMManager
import com.tencent.imsdk.v2.V2TIMOfficialAccountInfo
import com.tencent.imsdk.v2.V2TIMOfficialAccountInfoResult
import com.tencent.imsdk.v2.V2TIMValueCallback
import com.tencent.qcloud.tuicore.interfaces.TUICallback
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.bean.OfficialAccountInfo
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.bean.OfficialAccountPageResult
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.util.TUIOfficialAccountLog

class OfficialAccountProvider {
    companion object {
        private const val TAG = "OfficialAccountProvider"
    }

    fun loadSubscribedOfficialAccounts(callback: TUIValueCallback<List<OfficialAccountInfo>>) {
        TUIOfficialAccountLog.i(TAG, "loadSubscribedOfficialAccounts")
        
        V2TIMManager.getFriendshipManager().getOfficialAccountsInfo(
            emptyList(),
            object : V2TIMValueCallback<List<V2TIMOfficialAccountInfoResult>> {
                override fun onSuccess(results: List<V2TIMOfficialAccountInfoResult>?) {
                    val officialAccounts = mutableListOf<OfficialAccountInfo>()
                    
                    results?.forEach { result ->
                        result.officialAccountInfo?.let { v2Info ->
                            if (v2Info.subscribeTime > 0) {
                                val account = convertToOfficialAccountInfo(v2Info)
                                officialAccounts.add(account)
                            }
                        }
                    }
                    
                    TUIOfficialAccountLog.i(TAG, "loadSubscribedOfficialAccounts success, count: ${officialAccounts.size}")
                    callback.onSuccess(officialAccounts)
                }
                
                override fun onError(code: Int, desc: String?) {
                    TUIOfficialAccountLog.e(TAG, "loadSubscribedOfficialAccounts failed, code:$code, desc:$desc")
                    callback.onError(code, desc ?: "Unknown error")
                }
            })
    }

    fun loadOfficialAccounts(
        count: Int, 
        offset: Long, 
        callback: TUIValueCallback<OfficialAccountPageResult>
    ) {
        TUIOfficialAccountLog.i(TAG, "loadAllOfficialAccounts with pagination, count: $count, offset: $offset")
        
        try {
            val param = org.json.JSONObject().apply {
                put("count", count)
                put("offset", offset)
            }
            
            V2TIMManager.getInstance().callExperimentalAPI(
                "getOfficialAccountList", 
                param.toString(), 
                object : V2TIMValueCallback<Any> {
                    override fun onSuccess(result: Any?) {
                        if (result is HashMap<*, *>) {
                            val resultMap = result as HashMap<String, Any>
                            val totalCountObj = resultMap["total_count"] as? Int
                            val nextOffsetObj = resultMap["next_offset"] as? Long
                            val officialAccountList = resultMap["official_account_list"] as? List<V2TIMOfficialAccountInfo>
                            
                            val totalCount = totalCountObj ?: 0
                            val nextOffset = nextOffsetObj ?: 0L
                            val accounts = officialAccountList ?: emptyList()
                            
                            val officialAccounts = accounts.map { v2Info ->
                                convertToOfficialAccountInfo(v2Info)
                            }
                            
                            val pageResult = OfficialAccountPageResult(
                                officialAccounts = officialAccounts,
                                totalCount = totalCount,
                                nextOffset = nextOffset,
                                hasMore = nextOffset > 0
                            )
                            
                            TUIOfficialAccountLog.i(TAG, "loadAllOfficialAccounts success, totalCount: $totalCount, count: ${officialAccounts.size}, nextOffset: $nextOffset, hasMore: ${pageResult.hasMore}")
                            callback.onSuccess(pageResult)
                        } else {
                            TUIOfficialAccountLog.e(TAG, "loadAllOfficialAccounts failed: result is not HashMap")
                            callback.onError(-1, "Invalid result format")
                        }
                    }
                    
                    override fun onError(code: Int, desc: String?) {
                        TUIOfficialAccountLog.e(TAG, "loadAllOfficialAccounts failed, code:$code, desc:$desc")
                        callback.onError(code, desc ?: "Unknown error")
                    }
                }
            )
        } catch (e: Exception) {
            TUIOfficialAccountLog.e(TAG, "loadAllOfficialAccounts exception: ${e.message}")
            callback.onError(-1, "Exception occurred: ${e.message}")
        }
    }

    fun loadOfficialAccountInfo(officialAccountId: String, callback: TUIValueCallback<OfficialAccountInfo>) {
        TUIOfficialAccountLog.i(TAG, "loadOfficialAccountInfo: $officialAccountId")
        
        V2TIMManager.getFriendshipManager().getOfficialAccountsInfo(
            listOf(officialAccountId),
            object : V2TIMValueCallback<List<V2TIMOfficialAccountInfoResult>> {
                override fun onSuccess(results: List<V2TIMOfficialAccountInfoResult>?) {
                    results?.firstOrNull()?.officialAccountInfo?.let { v2Info ->
                        val info = convertToOfficialAccountInfo(v2Info)
                        TUIOfficialAccountLog.i(TAG, "loadOfficialAccountInfo success: ${info.name}")
                        callback.onSuccess(info)
                    } ?: run {
                        TUIOfficialAccountLog.e(TAG, "loadOfficialAccountInfo failed: no data")
                        callback.onError(-1, "No official account info found")
                    }
                }
                
                override fun onError(code: Int, desc: String?) {
                    TUIOfficialAccountLog.e(TAG, "loadOfficialAccountInfo failed, code:$code, desc:$desc")
                    callback.onError(code, desc ?: "Unknown error")
                }
            })
    }
    

    fun subscribeOfficialAccount(officialAccountId: String, callback: TUICallback) {
        TUIOfficialAccountLog.i(TAG, "subscribeOfficialAccount: $officialAccountId")
        
        V2TIMManager.getFriendshipManager().subscribeOfficialAccount(
            officialAccountId,
            object : V2TIMCallback {
                override fun onSuccess() {
                    TUIOfficialAccountLog.i(TAG, "subscribeOfficialAccount success")
                    callback.onSuccess()
                }
                
                override fun onError(code: Int, desc: String?) {
                    TUIOfficialAccountLog.e(TAG, "subscribeOfficialAccount failed, code:$code, desc:$desc")
                    callback.onError(code, desc ?: "Unknown error")
                }
            })
    }
    
    fun unsubscribeOfficialAccount(officialAccountId: String, callback: TUICallback) {
        TUIOfficialAccountLog.i(TAG, "unsubscribeOfficialAccount: $officialAccountId")
        
        V2TIMManager.getFriendshipManager().unsubscribeOfficialAccount(
            officialAccountId,
            object : V2TIMCallback {
                override fun onSuccess() {
                    TUIOfficialAccountLog.i(TAG, "unsubscribeOfficialAccount success")
                    callback.onSuccess()
                }
                
                override fun onError(code: Int, desc: String?) {
                    TUIOfficialAccountLog.e(TAG, "unsubscribeOfficialAccount failed, code:$code, desc:$desc")
                    callback.onError(code, desc ?: "Unknown error")
                }
            })
    }

    fun checkSubscriptionStatus(officialAccountId: String, callback: TUIValueCallback<Boolean>) {
        TUIOfficialAccountLog.i(TAG, "checkSubscriptionStatus: $officialAccountId")
        
        V2TIMManager.getFriendshipManager().getOfficialAccountsInfo(
            listOf(officialAccountId),
            object : V2TIMValueCallback<List<V2TIMOfficialAccountInfoResult>> {
                override fun onSuccess(results: List<V2TIMOfficialAccountInfoResult>?) {
                    val isSubscribed = results?.firstOrNull()?.officialAccountInfo?.subscribeTime ?: 0 > 0
                    TUIOfficialAccountLog.i(TAG, "checkSubscriptionStatus success: $isSubscribed")
                    callback.onSuccess(isSubscribed)
                }
                
                override fun onError(code: Int, desc: String?) {
                    TUIOfficialAccountLog.e(TAG, "checkSubscriptionStatus failed, code:$code, desc:$desc")
                    callback.onError(code, desc ?: "Unknown error")
                }
            })
    }

    fun getConversationLastMessages(
        officialAccountIds: List<String>, 
        callback: TUIValueCallback<Map<String, String?>>
    ) {
        if (officialAccountIds.isEmpty()) {
            TUIOfficialAccountLog.i(TAG, "getConversationLastMessagesBatch: empty list")
            callback.onSuccess(emptyMap())
            return
        }
        
        TUIOfficialAccountLog.i(TAG, "getConversationLastMessagesBatch: ${officialAccountIds.size} accounts")
        
        val conversationIdList = officialAccountIds.map { "c2c_$it" }
        
        V2TIMManager.getConversationManager().getConversationList(
            conversationIdList,
            object : V2TIMValueCallback<List<V2TIMConversation>> {
                override fun onSuccess(conversations: List<V2TIMConversation>?) {
                    val resultMap = mutableMapOf<String, String?>()
                    
                    val conversationIdToAccountId = officialAccountIds.associateBy { "c2c_$it" }
                    conversations?.forEach { conversation ->
                        val accountId = conversationIdToAccountId[conversation.conversationID]
                        if (accountId != null) {
                            val displayString = ChatMessageParser.getDisplayString(conversation.lastMessage)
                            resultMap[accountId] = displayString
                        }
                    }
                    
                    officialAccountIds.forEach { accountId ->
                        if (!resultMap.containsKey(accountId)) {
                            resultMap[accountId] = null
                        }
                    }
                    
                    TUIOfficialAccountLog.i(TAG, "getConversationLastMessagesBatch success: ${resultMap.size} results")
                    callback.onSuccess(resultMap)
                }
                
                override fun onError(code: Int, desc: String?) {
                    TUIOfficialAccountLog.e(TAG, "getConversationLastMessagesBatch failed, code:$code, desc:$desc")
                    val emptyResultMap = officialAccountIds.associateWith { null }
                    callback.onSuccess(emptyResultMap)
                }
            })
    }
    

    private fun convertToOfficialAccountInfo(v2Info: V2TIMOfficialAccountInfo): OfficialAccountInfo {
        return OfficialAccountInfo(
            officialAccount = v2Info.officialAccountID,
            ownerAccount = v2Info.ownerUserID ?: "",
            name = v2Info.officialAccountName ?: "",
            introduction = v2Info.introduction ?: "",
            faceUrl = v2Info.faceUrl ?: "",
            subscriberNum = v2Info.subscriberCount,
            createTime = v2Info.createTime,
            organization = v2Info.organization ?: "",
            customString = v2Info.customData ?: ""
        )
    }
}

