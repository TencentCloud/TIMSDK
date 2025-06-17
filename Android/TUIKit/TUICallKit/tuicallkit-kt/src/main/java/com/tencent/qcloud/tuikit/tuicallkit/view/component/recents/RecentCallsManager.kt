package com.tencent.qcloud.tuikit.tuicallkit.view.component.recents

import android.content.Context
import android.text.TextUtils
import com.tencent.cloud.tuikit.engine.call.TUICallDefine.CallRecords
import com.tencent.cloud.tuikit.engine.call.TUICallDefine.RecentCallsFilter
import com.tencent.cloud.tuikit.engine.call.TUICallEngine
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine
import com.trtc.tuikit.common.livedata.LiveListData
import java.util.concurrent.CopyOnWriteArrayList

class RecentCallsManager(context: Context) {
    private val context: Context = context.applicationContext
    var callHistoryList: LiveListData<CallRecords> = LiveListData<CallRecords>(CopyOnWriteArrayList())
    var callMissedList: LiveListData<CallRecords> = LiveListData<CallRecords>(CopyOnWriteArrayList())

    fun queryRecentCalls(filter: RecentCallsFilter?) {
        TUICallEngine.createInstance(context).queryRecentCalls(filter, object : TUICommonDefine.ValueCallback<Any?> {
            override fun onSuccess(data: Any?) {
                if (data == null || data !is List<*>) {
                    return
                }
                val queryList = data as ArrayList<CallRecords>
                if (filter != null && CallRecords.Result.Missed == filter.result) {
                    val missList: ArrayList<CallRecords> = ArrayList(callMissedList.list)
                    missList.removeAll(queryList)
                    missList.addAll(queryList)
                    callMissedList.replaceAll(missList)
                } else {
                    val historyList: ArrayList<CallRecords> = ArrayList(callHistoryList.list)
                    historyList.removeAll(queryList)
                    historyList.addAll(queryList)
                    callHistoryList.replaceAll(historyList.toList())
                }
            }

            override fun onError(errCode: Int, errMsg: String) {}
        })
    }

    fun deleteRecordCalls(list: List<CallRecords>?) {
        if (list.isNullOrEmpty()) {
            return
        }
        val missList = ArrayList(callMissedList.list)
        missList.removeAll(list)
        callMissedList.replaceAll(missList)
        val allList: MutableList<CallRecords> = ArrayList(callHistoryList.list)
        allList.removeAll(list)
        callHistoryList.replaceAll(allList)
        val callIdList: MutableList<String> = ArrayList()
        for (record in list) {
            if (!TextUtils.isEmpty(record.callId)) {
                callIdList.add(record.callId)
            }
        }
        TUICallEngine.createInstance(context).deleteRecordCalls(callIdList,
            object : TUICommonDefine.ValueCallback<Any?> {
                override fun onSuccess(data: Any?) {}
                override fun onError(errCode: Int, errMsg: String) {}
            })
    }
}