package com.tencent.qcloud.tuikit.tuiconversation.classicui.interfaces;

import android.view.View;

import com.tencent.qcloud.tuikit.tuiconversation.classicui.widget.ConversationListAdapter;
import com.tencent.qcloud.tuikit.tuiconversation.interfaces.IConversationListAdapter;

public interface IConversationListLayout {
    void setBackground(int resId);

    void setOnConversationAdapterListener(OnConversationAdapterListener listener);

    /**
     * Do not display the switch for the number of unread messages with the small red dot
     *
     * @param flag false，
     */
    void disableItemUnreadDot(boolean flag);

    View getListLayout();

    ConversationListAdapter getAdapter();

    void setAdapter(IConversationListAdapter adapter);
}
