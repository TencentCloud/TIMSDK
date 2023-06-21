package com.tencent.qcloud.tuikit.tuigroup.interfaces;

import android.content.Context;

import com.tencent.qcloud.tuikit.tuigroup.bean.GroupApplyInfo;

import java.util.List;

public interface IGroupApplyLayout {
    default void onGroupApplyInfoListChanged(List<GroupApplyInfo> dataSource) {}

    default void onDataSetChanged() {}

    default Context getContext() {
        return null;
    }
}
