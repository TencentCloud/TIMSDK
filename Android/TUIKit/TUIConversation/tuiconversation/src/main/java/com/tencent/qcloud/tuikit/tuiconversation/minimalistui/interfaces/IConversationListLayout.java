package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.interfaces;

import android.view.View;

import com.tencent.qcloud.tuikit.tuiconversation.interfaces.IConversationListAdapter;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget.ConversationListAdapter;

public interface IConversationListLayout {
    void setBackground(int resId);

    void setOnConversationAdapterListener(OnConversationAdapterListener listener);

    /**
     * Do not display the switch for the number of unread messages with the small red dot
     */
    void disableItemUnreadDot(boolean flag);

    View getListLayout();

    ConversationListAdapter getAdapter();

    void setAdapter(IConversationListAdapter adapter);
}
