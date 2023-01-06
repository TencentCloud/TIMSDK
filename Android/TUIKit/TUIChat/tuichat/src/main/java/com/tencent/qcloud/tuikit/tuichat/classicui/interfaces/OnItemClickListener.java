package com.tencent.qcloud.tuikit.tuichat.classicui.interfaces;

import android.view.View;

import com.tencent.qcloud.tuikit.tuichat.bean.message.QuoteMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;

public abstract class OnItemClickListener {
    public void onMessageLongClick(View view, int position, TUIMessageBean messageInfo) {};

    public void onMessageClick(View view, int position, TUIMessageBean messageInfo) {};

    public void onUserIconClick(View view, int position, TUIMessageBean messageInfo) {};

    public void onUserIconLongClick(View view, int position, TUIMessageBean messageInfo) {};

    public void onReEditRevokeMessage(View view, int position, TUIMessageBean messageInfo) {};

    public void onRecallClick(View view, int position, TUIMessageBean messageInfo) {};

    public  void onReplyMessageClick(View view, int position, QuoteMessageBean messageBean) {}

    public  void onReplyDetailClick(TUIMessageBean messageBean) {}

    public  void onReactOnClick(String emojiId, TUIMessageBean messageBean) {}

    public  void onSendFailBtnClick(View view, int position, TUIMessageBean messageInfo) {};

    public  void onTextSelected(View view, int position, TUIMessageBean messageInfo) {};

    public void onTranslationLongClick(View view, int position, TUIMessageBean messageInfo) {};
}
