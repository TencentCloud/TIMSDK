package com.tencent.qcloud.uikit.business.contact.view.event;

import android.view.View;


public interface ContactPanelEvent {
    void onAddContactClick(View view, String identify);

    void onDelContactClick(View view, String identify);

    void onItemClick(View view, int position);
}
