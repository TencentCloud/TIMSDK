package com.tencent.qcloud.tuikit.timcommon.interfaces;

import android.view.View;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;

public abstract class OnItemClickListener {
    public void onMessageLongClick(View view, int position, TUIMessageBean messageBean) {}

    public void onMessageClick(View view, int position, TUIMessageBean messageBean) {}

    public void onUserIconClick(View view, int position, TUIMessageBean messageBean) {}

    public void onUserIconLongClick(View view, int position, TUIMessageBean messageBean) {}

    public void onReEditRevokeMessage(View view, int position, TUIMessageBean messageBean) {}

    public void onRecallClick(View view, int position, TUIMessageBean messageBean) {}

    public void onReplyMessageClick(View view, int position, TUIMessageBean messageBean) {}

    public void onReplyDetailClick(TUIMessageBean messageBean) {}

    public void onReactOnClick(String emojiId, TUIMessageBean messageBean) {}

    public void onSendFailBtnClick(View view, int position, TUIMessageBean messageBean) {}

    public void onTextSelected(View view, int position, TUIMessageBean messageBean) {}

    public void onMessageReadStatusClick(View view, TUIMessageBean messageBean) {}
}
