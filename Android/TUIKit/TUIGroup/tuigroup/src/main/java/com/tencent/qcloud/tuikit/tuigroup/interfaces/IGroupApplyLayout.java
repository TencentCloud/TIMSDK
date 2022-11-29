package com.tencent.qcloud.tuikit.tuigroup.interfaces;

import android.content.Context;

import com.tencent.qcloud.tuikit.tuigroup.bean.GroupApplyInfo;

import java.util.List;

public interface IGroupApplyLayout {
    void onGroupApplyInfoListChanged(List<GroupApplyInfo> dataSource);
    void onDataSetChanged();
    Context getContext();

}
