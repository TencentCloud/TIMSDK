package com.tencent.qcloud.tuikit.tuiconversation.ui.interfaces;

import android.view.View;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;

public interface OnItemLongClickListener {
    void OnItemLongClick(View view, ConversationInfo messageInfo);
}
