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

    /**
     * Set session item avatar rounded corners
     *
     * @param radius
     */
    void setItemAvatarRadius(int radius);

    /**
     * Set the font size at the top of the session item
     *
     * @param size
     */
    void setItemTopTextSize(int size);

    /**
     * Set the font size at the bottom of the session item
     *
     * @param size
     */
    void setItemBottomTextSize(int size);

    /**
     * Set the session item date font size
     *
     * @param size
     */
    void setItemDateTextSize(int size);

    View getListLayout();

    ConversationListAdapter getAdapter();

    void setAdapter(IConversationListAdapter adapter);
}
