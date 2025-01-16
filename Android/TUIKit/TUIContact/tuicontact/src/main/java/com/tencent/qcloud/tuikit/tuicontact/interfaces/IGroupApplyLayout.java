package com.tencent.qcloud.tuikit.tuicontact.interfaces;

import android.content.Context;

import com.tencent.qcloud.tuikit.tuicontact.bean.GroupApplyInfo;

import java.util.List;

public interface IGroupApplyLayout {
    default void onGroupApplyInfoListChanged(List<GroupApplyInfo> dataSource) {}

    default void onDataSetChanged() {}

    default Context getContext() {
        return null;
    }
}
