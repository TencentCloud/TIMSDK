package com.tencent.qcloud.uikit.api.chat;


import com.tencent.qcloud.uikit.common.component.action.PopMenuAction;
import com.tencent.qcloud.uikit.business.chat.view.widget.MessageOperaUnit;
import com.tencent.qcloud.uikit.business.chat.view.widget.ChatListEvent;

import java.util.List;


public interface IChatPanel {

    /**
     * 设置当前的会话ID，会话面板会依据该ID加载会话所需的相关信息，如消息记录，用户（群）信息等
     *
     * @param chatId
     */
    void setBaseChatId(String chatId);

    /**
     * 设置聊天面板的适配器{@link com.tencent.qcloud.uikit.business.chat.view.widget.ChatAdapter}
     *
     * @param adapter
     */
    void setChatAdapter(IChatAdapter adapter);

    /**
     * 设置聊天列表的事件监听器{@link com.tencent.qcloud.uikit.business.chat.view.widget.ChatListEvent}
     *
     * @param event
     */
    void setChatListEvent(ChatListEvent event);

    /**
     * 设置底部更多消息操作集合，如图片消息操作，摄像消息操作等，开发者可定制化
     *
     * @param units 消息操作集合
     * @param isAdd 是否为添加，true为在默认实现后添加，false为覆盖
     */
    void setMoreOperaUnits(List<MessageOperaUnit> units, boolean isAdd);


    /**
     * 设置长按消息时弹框列表
     *
     * @param actions 弹框事件集合
     * @param isAdd   是否为添加，true为添加事件，false为覆盖组件以定义事件
     */
    void setMessagePopActions(List<PopMenuAction> actions, boolean isAdd);

    /**
     * 依据当前的聊天数据主动刷新聊天界面
     */
    void refreshData();


    /**
     * 退出聊天，释放相关资源（一般在activity finish时调用）
     */
    void exitChat();

    /**
     * 使用初始化配置（即使用UIKIT sdk中聊天面板的默认配置）
     */
    void initDefault();
}
