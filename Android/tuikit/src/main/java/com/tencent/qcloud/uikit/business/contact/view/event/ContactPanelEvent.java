package com.tencent.qcloud.uikit.business.contact.view.event;

import android.view.View;

/**
 * Created by valexhuang on 2018/6/28.
 */

public interface ContactPanelEvent {
    public void onAddContactClick(View view, String identify);

    public void onDelContactClick(View view, String identify);

    void onItemClick(View view, int position);
}
