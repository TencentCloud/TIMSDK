package com.tencent.qcloud.tuikit.tuicallkit.extensions.recents.interfaces

import android.view.View
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine.CallRecords

interface ICallRecordItemListener {
    fun onItemClick(view: View?, viewType: Int, callRecords: CallRecords?)
    fun onItemDeleteClick(view: View?, viewType: Int, callRecords: CallRecords?)
    fun onDetailViewClick(view: View?, callRecords: CallRecords?)
}