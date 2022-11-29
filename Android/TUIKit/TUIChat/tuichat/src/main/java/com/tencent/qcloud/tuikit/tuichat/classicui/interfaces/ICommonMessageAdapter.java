package com.tencent.qcloud.tuikit.tuichat.classicui.interfaces;

import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;

public interface ICommonMessageAdapter {
    TUIMessageBean getItem(int position);
    void notifyItemChanged(int position);
}
