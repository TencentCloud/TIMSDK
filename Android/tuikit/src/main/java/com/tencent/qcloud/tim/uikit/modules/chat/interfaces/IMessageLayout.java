package com.tencent.qcloud.tim.uikit.modules.chat.interfaces;

import com.tencent.qcloud.tim.uikit.component.action.PopMenuAction;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageListAdapter;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.IOnCustomMessageDrawListener;

import java.util.List;

public interface IMessageLayout extends IMessageProperties {

    /**
     * 设置消息列表的适配器{@link MessageListAdapter}
     *
     * @param adapter
     */
    void setAdapter(MessageListAdapter adapter);

    /**
     * 设置消息列表的事件监听器{@link MessageLayout.OnItemClickListener}
     *
     * @param listener
     */
    void setOnItemClickListener(MessageLayout.OnItemClickListener listener);

    /**
     * 获得消息列表的点击事件
     *
     * @return
     */
    MessageLayout.OnItemClickListener getOnItemClickListener();

    /**
     * 获取PopMenu的Action列表
     *
     * @return
     */
    List<PopMenuAction> getPopActions();

    /**
     * 给PopMenu加入一条自定义action
     *
     * @param action 菜单选项{@link PopMenuAction}, 可以自定义图片、文字以及点击事件
     */
    void addPopAction(PopMenuAction action);

    /**
     * 设置自定义的消息渲染时的回调，当TUIKit内部在刷新自定义消息时会调用这个回调
     *
     * @param listener {@link IOnCustomMessageDrawListener}
     */
    void setOnCustomMessageDrawListener(IOnCustomMessageDrawListener listener);
}
