package com.tencent.qcloud.tuikit.tuiconversation.ui.interfaces;

import android.view.View;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;

public interface OnItemClickListener {
    void onItemClick(View view, int viewType, ConversationInfo messageInfo);
}
