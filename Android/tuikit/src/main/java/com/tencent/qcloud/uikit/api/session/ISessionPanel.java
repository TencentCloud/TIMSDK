package com.tencent.qcloud.uikit.api.session;

import com.tencent.qcloud.uikit.business.session.view.DynamicSessionIconView;
import com.tencent.qcloud.uikit.business.session.view.wedgit.SessionClickListener;
import com.tencent.qcloud.uikit.business.session.view.wedgit.SessionListEvent;
import com.tencent.qcloud.uikit.common.component.action.PopMenuAction;
import com.tencent.qcloud.uikit.common.widget.DynamicLayoutView;

import java.util.List;

/**
 * 会话面板类(SessionPanel)实现的业务接口
 */

public interface ISessionPanel {

    /**
     * 设置会话面板的Listview的适配器{@link com.tencent.qcloud.uikit.api.session.ISessionAdapter}
     *
     * @param adapter
     */
    void setSessionAdapter(ISessionAdapter adapter);


    /**
     * 设置会话列表点击回调事件，控制会话点击时的界面跳转
     *
     * @param clickListener
     */
    void setSessionClick(SessionClickListener clickListener);


    /**
     * 设置更多弹框的Action,开发者可调用该接口修改默认的更多弹框操作
     *
     * @param actions PopMenuAction集合
     * @param isAdd   是否为添加，ture为在默认的弹框集合上添加新的item,false再替换默认的
     */
    public void setMorePopActions(List<PopMenuAction> actions, boolean isAdd);


    /**
     * 设置会话长按弹框的Action,开发者可调用该接口修改默认的会话长按操作
     *
     * @param actions PopMenuAction集合
     * @param isAdd   是否为添加，ture为在默认的弹框集合上添加新的item,false再替换默认的
     */
    void setSessionPopActions(List<PopMenuAction> actions, boolean isAdd);

    /**
     * 设置会话列表其它事件(除单击事件外)监听器，不设置则用默认实现
     *
     * @param {SessionListEvent} event
     */
    void setSessionListEvent(SessionListEvent event);


    /**
     * 依据数据源强行刷新会话面板界面
     */
    void refresh();

    /**
     * 开放会话头像编辑功能，开发者可在头像的布局里添加元素（如添加挂件，头衔等）
     *
     * @param dynamicIconView
     */
    void setSessionIconInvoke(DynamicSessionIconView dynamicIconView);

    /**
     * SessionPanel的默认初始化设置，会初始化弹框，长按事件等
     */
    void initDefault();


}
