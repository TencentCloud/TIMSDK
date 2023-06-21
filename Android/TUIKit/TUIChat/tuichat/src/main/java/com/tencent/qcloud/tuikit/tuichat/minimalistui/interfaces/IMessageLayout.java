package com.tencent.qcloud.tuikit.tuichat.minimalistui.interfaces;

import com.tencent.qcloud.tuikit.timcommon.interfaces.IMessageProperties;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.MessageAdapter;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.messagepopmenu.ChatPopActivity;
import java.util.List;

/**
 * 消息区域 {@link com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.MessageRecyclerView} 继承自 {@link RecyclerView}，提供了消息的展示功能。<br>
 * 本类提供了大量的方法以供定制化需求，包括外观设置、事件点击，以及自定义消息的展示等。
 *
 * The message area {@link com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.MessageRecyclerView} inherits from {@link RecyclerView} and provides the
 * display function of the message. This class provides a large number of methods for customization requirements, including appearance settings, event clicks,
 * and display of custom messages.
 */
public interface IMessageLayout extends IMessageProperties {
    /**
     * 设置消息列表的适配器 {@link com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.MessageAdapter}
     *
     * @param adapter
     */
    void setAdapter(MessageAdapter adapter);

    /**
     * 获得消息列表的点击事件
     *
     * @return
     */
    OnItemClickListener getOnItemClickListener();

    /**
     * 设置消息列表的事件监听器 {@link com.tencent.qcloud.tuikit.timcommon.interfaces.OnItemClickListener}
     *
     * @param listener
     */
    void setOnItemClickListener(OnItemClickListener listener);

    /**
     * 获取 PopMenu 的 Action 列表
     *
     * @return
     */
    List<ChatPopActivity.ChatPopMenuAction> getPopActions();

    /**
     * 给 PopMenu 加入一条自定义 action
     *
     * @param action 菜单选项 {@link com.tencent.qcloud.tuicore.component.action.PopMenuAction}, 可以自定义图片、文字以及点击事件
     */
    void addPopAction(ChatPopActivity.ChatPopMenuAction action);
}
