package com.tencent.qcloud.tuikit.tuichat.classicui.interfaces;

import com.tencent.qcloud.tuikit.timcommon.interfaces.IMessageProperties;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.popmenu.ChatPopMenu;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.MessageAdapter;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.MessageRecyclerView;

import java.util.List;

/**
 * The message area {@link MessageRecyclerView} inherits from {@link RecyclerView} and provides the display function of the message.
 * This class provides a large number of methods for customization requirements, including appearance settings, event clicks,
 * and display of custom messages.
 */
public interface IMessageLayout extends IMessageProperties {

    void setAdapter(MessageAdapter adapter);

    OnItemClickListener getOnItemClickListener();

    void setOnItemClickListener(OnItemClickListener listener);

    List<ChatPopMenu.ChatPopMenuAction> getPopActions();

    void addPopAction(ChatPopMenu.ChatPopMenuAction action);
}
