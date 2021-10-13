package com.tencent.qcloud.tuikit.tuichat.ui.interfaces;


import com.tencent.qcloud.tuikit.tuichat.bean.MessageInfo;

public interface ICommonMessageAdapter {
    MessageInfo getItem(int position);
    void notifyItemChanged(int position);
}
