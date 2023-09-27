package com.tencent.qcloud.tuikit.tuicallkit.extensions.recents

import android.app.Application
import android.text.TextUtils
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.MutableLiveData
import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine.CallRecords
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine.RecentCallsFilter
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine

class RecentCallsViewModel(application: Application) : AndroidViewModel(application) {
    val callHistoryList = MutableLiveData<MutableList<CallRecords>?>()
    val callMissedList = MutableLiveData<MutableList<CallRecords>?>()

    init {
        callHistoryList.value = ArrayList()
        callMissedList.value = ArrayList()
    }

    fun queryRecentCalls(filter: RecentCallsFilter?) {
        TUICallEngine.createInstance(getApplication())
            .queryRecentCalls(filter, object : TUICommonDefine.ValueCallback<Any?> {
                override fun onSuccess(data: Any?) {
                    if (data == null || data !is List<*>) {
                        return
                    }
                    val queryList = data as List<CallRecords>
                    if (filter != null && CallRecords.Result.Missed == filter.result) {
                        val missList = callMissedList.value
                        if (missList != null) {
                            missList.removeAll(queryList)
                            missList.addAll(queryList)
                        }
                        callMissedList.setValue(missList)
                    } else {
                        val historyList = callHistoryList.value
                        if (historyList != null) {
                            historyList.removeAll(queryList)
                            historyList.addAll(queryList)
                        }
                        callHistoryList.setValue(historyList)
                    }
                }

                override fun onError(errCode: Int, errMsg: String) {}
            })
    }

    fun deleteRecordCalls(list: List<CallRecords>?) {
        if (list.isNullOrEmpty()) {
            return
        }
        val missList = ArrayList(callMissedList.value)
        missList.removeAll(list)
        callMissedList.value = missList
        val allList: MutableList<CallRecords> = ArrayList(callHistoryList.value)
        allList.removeAll(list)
        callHistoryList.value = allList
        val callIdList: MutableList<String> = ArrayList()
        for (record in list) {
            if (record != null && !TextUtils.isEmpty(record.callId)) {
                callIdList.add(record.callId)
            }
        }
        TUICallEngine.createInstance(getApplication()).deleteRecordCalls(callIdList,
            object : TUICommonDefine.ValueCallback<Any?> {
                override fun onSuccess(data: Any?) {}
                override fun onError(errCode: Int, errMsg: String) {}
            })
    }

    companion object {
        private const val TAG = "RecentCallsViewModel"
    }
}