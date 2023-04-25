package com.tencent.qcloud.tuikit.tuicallkit.extensions.recents.interfaces;

import android.view.View;

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;

public interface ICallRecordItemListener {
    void onItemClick(View view, int viewType, TUICallDefine.CallRecords callRecords);

    void onItemDeleteClick(View view, int viewType, TUICallDefine.CallRecords callRecords);

    void onDetailViewClick(View view, TUICallDefine.CallRecords callRecords);
}
