package com.tencent.qcloud.tuikit.tuicallkit.view.component.recents.interfaces

import android.view.View
import com.tencent.cloud.tuikit.engine.call.TUICallDefine.CallRecords

interface ICallRecordItemListener {
    fun onItemClick(view: View?, viewType: Int, callRecords: CallRecords?)
    fun onItemDeleteClick(view: View?, viewType: Int, callRecords: CallRecords?)
    fun onDetailViewClick(view: View?, callRecords: CallRecords?)
}