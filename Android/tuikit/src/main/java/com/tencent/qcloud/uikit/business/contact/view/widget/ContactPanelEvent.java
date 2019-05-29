package com.tencent.qcloud.uikit.business.contact.view.widget;

import android.view.View;

// 重复代码，待删除
public interface ContactPanelEvent {
    void onAddContactClick(View view, String identify);

    void onDelContactClick(View view, String identify);

    void onItemClick(View view, int position);
}
