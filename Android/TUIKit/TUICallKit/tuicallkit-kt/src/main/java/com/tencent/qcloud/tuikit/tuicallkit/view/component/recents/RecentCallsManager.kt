package com.tencent.qcloud.tuikit.tuicallkit.view.component.recents

import android.text.TextUtils
import com.trtc.tuikit.common.livedata.LiveListData
import io.trtc.tuikit.atomicxcore.api.CompletionHandler
import io.trtc.tuikit.atomicxcore.api.call.CallDirection
import io.trtc.tuikit.atomicxcore.api.call.CallInfo
import io.trtc.tuikit.atomicxcore.api.call.CallStore
import java.util.concurrent.CopyOnWriteArrayList

class RecentCallsManager {
    var callHistoryList: LiveListData<CallInfo> = LiveListData<CallInfo>(CopyOnWriteArrayList())
    var callMissedList: LiveListData<CallInfo> = LiveListData<CallInfo>(CopyOnWriteArrayList())

    fun queryRecentCalls(filter: CallInfo?) {
        CallStore.shared.queryRecentCalls("", 0, object : CompletionHandler {
            override fun onSuccess() {
                val recentCalls = CallStore.shared.observerState.recentCalls.value
                val sortedRecentCalls = recentCalls.sortedByDescending { it.startTime }
                if (filter != null && CallDirection.Missed == filter.result) {
                    val missList = sortedRecentCalls.filter { it.result == CallDirection.Missed }
                    callMissedList.replaceAll(missList)
                } else {
                    callHistoryList.replaceAll(sortedRecentCalls)
                }
            }

            override fun onFailure(code: Int, desc: String) {

            }

        })
    }

    fun deleteRecordCalls(list: List<CallInfo>?) {
        if (list.isNullOrEmpty()) {
            return
        }
        val missList = ArrayList(callMissedList.list)
        missList.removeAll(list)
        callMissedList.replaceAll(missList)
        val allList: MutableList<CallInfo> = ArrayList(callHistoryList.list)
        allList.removeAll(list)
        callHistoryList.replaceAll(allList)
        val callIdList: MutableList<String> = ArrayList()
        for (record in list) {
            if (!TextUtils.isEmpty(record.callId)) {
                callIdList.add(record.callId)
            }
        }
        CallStore.shared.deleteRecentCalls(callIdList, null)
    }
}