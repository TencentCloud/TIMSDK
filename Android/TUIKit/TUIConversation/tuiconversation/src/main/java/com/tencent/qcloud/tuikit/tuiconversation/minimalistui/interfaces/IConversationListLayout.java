package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.interfaces;

import android.view.View;

import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.interfaces.OnConversationAdapterListener;
import com.tencent.qcloud.tuikit.tuiconversation.interfaces.IConversationListAdapter;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget.ConversationListAdapter;

public interface IConversationListLayout {
    void setBackground(int resId);
    void setOnConversationAdapterListener(OnConversationAdapterListener listener);

    /**
     * 不显示小红点未读消息条数开关
     * 
     * Do not display the switch for the number of unread messages with the small red dot
     *
     * @param flag 默认false，表示显示
     */
    void disableItemUnreadDot(boolean flag);

    /**
     * 设置会话Item头像圆角
     * 
     * Set session item avatar rounded corners
     *
     * @param radius
     */
    void setItemAvatarRadius(int radius);

    /**
     * 设置会话Item顶部字体大小
     * 
     * Set the font size at the top of the session item
     *
     * @param size
     */
    void setItemTopTextSize(int size);

    /**
     * 设置会话Item底部字体大小
     * 
     * Set the font size at the bottom of the session item
     *
     * @param size
     */
    void setItemBottomTextSize(int size);

    /**
     * 设置会话Item日期字体大小
     * 
     * Set the session item date font size
     *
     * @param size
     */
    void setItemDateTextSize(int size);


    View getListLayout();
    ConversationListAdapter getAdapter();
    void setAdapter(IConversationListAdapter adapter);

}
