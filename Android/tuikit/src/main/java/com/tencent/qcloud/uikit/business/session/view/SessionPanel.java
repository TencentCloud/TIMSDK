package com.tencent.qcloud.uikit.business.session.view;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.RelativeLayout;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.api.session.ISessionAdapter;
import com.tencent.qcloud.uikit.api.session.ISessionPanel;
import com.tencent.qcloud.uikit.business.session.view.wedgit.SessionAdapter;
import com.tencent.qcloud.uikit.business.session.model.SessionInfo;
import com.tencent.qcloud.uikit.business.session.presenter.SessionPresenter;
import com.tencent.qcloud.uikit.business.session.view.wedgit.SessionClickListener;
import com.tencent.qcloud.uikit.common.component.action.PopActionClickListener;
import com.tencent.qcloud.uikit.operation.c2c.C2CChatStartActivity;
import com.tencent.qcloud.uikit.common.component.action.PopMenuAction;
import com.tencent.qcloud.uikit.business.session.view.wedgit.SessionListEvent;
import com.tencent.qcloud.uikit.common.component.action.PopMenuAdapter;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;
import com.tencent.qcloud.uikit.common.utils.PopWindowUtil;
import com.tencent.qcloud.uikit.common.utils.UIUtils;
import com.tencent.qcloud.uikit.operation.group.GroupChatCreateActivity;
import com.tencent.qcloud.uikit.operation.group.GroupChatJoinActivity;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by valxehuang on 2018/7/17.
 */

public class SessionPanel extends RelativeLayout implements ISessionPanel {
    /**
     * 会话面板标题栏
     */
    public PageTitleBar mTitleBar;
    /**
     * 会话ListView
     */
    public SessionListView mSessionList;
    /**
     * 会话List可接收的事件(除单击事件，单击事件参考{@link com.tencent.qcloud.uikit.business.session.view.wedgit.SessionClickListener})
     */
    private SessionListEvent mSessionEvent;

    /**
     * 单个会话长按弹出的事件列表
     */
    public ListView mSessionPopList;

    /**
     * 单个会话长按弹出的事件列表适配器
     */
    public PopMenuAdapter mSessionPopAdapter;

    /**
     * 标题栏右上角单击弹出的事件列表
     */
    public ListView mPopMenuList;

    /**
     * 标题栏右上角单击弹出的事件列表适配器
     */
    public PopMenuAdapter mMenuAdapter;


    public static SessionClickListener mSessionClickListener;
    private ISessionAdapter mAdapter;
    private DynamicSessionIconView mInfoView;
    private AlertDialog mPopMemuDialog;
    private PopupWindow mSessionPopWindow;
    private SessionPresenter mPresenter;
    private List<PopMenuAction> mMoreActions = new ArrayList<>();
    private List<PopMenuAction> mSessionPopActions = new ArrayList<>();


    public SessionPanel(Context context) {
        super(context);
        init();
    }

    public SessionPanel(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public SessionPanel(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }


    /**
     * 初始化相关UI元素
     */
    private void init() {
        inflate(getContext(), R.layout.session_panel, this);
        mTitleBar = findViewById(R.id.session_title_panel);
        mSessionList = findViewById(R.id.session_list);
        mSessionList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                if (mSessionClickListener != null)
                    mSessionClickListener.onSessionClick(mAdapter.getItem(i));
            }
        });
        mSessionList.setItemLongClickListener(new SessionListView.ItemLongClickListener() {
            @Override
            public void onItemLongClick(View view, int position, float x, float y) {
                showItemPopMenu(position, mAdapter.getItem(position), x, y);
            }
        });
    }

    /**
     * 右上角更多按钮点击时显示的弹框
     */
    private void showMorePopMenu() {
        if (mMoreActions == null || mMoreActions.size() == 0)
            return;
        if (mPopMemuDialog == null) {
            mMenuAdapter = new PopMenuAdapter();
            mMenuAdapter.setDataSource(mMoreActions);
            View mPopView = inflate(getContext(), R.layout.session_pop_menu, null);
            mPopMenuList = mPopView.findViewById(R.id.session_pop_list);
            mPopMenuList.setAdapter(mMenuAdapter);
            mPopMenuList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                    PopMenuAction action = (PopMenuAction) mMenuAdapter.getItem(position);
                    if (action != null && action.getActionClickListener() != null) {
                        action.getActionClickListener().onActionClick(position, mMoreActions.get(position));
                    }
                }
            });
            mPopMemuDialog = PopWindowUtil.buildCustomDialog((Activity) getContext());
            //mPopMemuDialog.getWindow().setBackgroundDrawableResource(R.drawable.top_pop);
            //mPopMemuDialog.setView(mPopView, 0, 0, 0, 0);
            mPopMemuDialog.show();
            WindowManager.LayoutParams lp = new WindowManager.LayoutParams();

            lp.width = UIUtils.getPxByDp(150);
            lp.height = LayoutParams.WRAP_CONTENT;
            lp.y = getResources().getDimensionPixelSize(R.dimen.page_title_height);
            lp.dimAmount = 0.5f;
            mPopMemuDialog.getWindow().setAttributes(lp);
            mPopMemuDialog.getWindow().setGravity(Gravity.TOP | Gravity.RIGHT);
            mPopMemuDialog.getWindow().addFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND);
            //mPopMemuDialog.getWindow().setBackgroundDrawable(null);
            mPopMemuDialog.setContentView(mPopView);
        } else {
            mPopMemuDialog.show();
        }

    }

    /**
     * 长按会话item弹框
     *
     * @param index       会话序列号
     * @param sessionInfo 会话数据对象
     * @param locationX   长按时X坐标
     * @param locationY   长按时Y坐标
     */
    private void showItemPopMenu(final int index, final SessionInfo sessionInfo, float locationX, float locationY) {
        if (mSessionPopActions == null || mSessionPopActions.size() == 0)
            return;
        View itemPop = inflate(getContext(), R.layout.pop_menu_layout, null);
        mSessionPopList = itemPop.findViewById(R.id.pop_menu_list);
        mSessionPopList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                PopMenuAction action = mSessionPopActions.get(position);
                if (action.getActionClickListener() != null) {
                    action.getActionClickListener().onActionClick(index, sessionInfo);
                }
                mSessionPopWindow.dismiss();
            }
        });

        for (int i = 0; i < mSessionPopActions.size(); i++) {
            PopMenuAction action = mSessionPopActions.get(i);
            if (sessionInfo.isTop()) {
                if (action.getActionName().equals("置顶聊天")) {
                    action.setActionName("取消置顶");
                }
            } else {
                if (action.getActionName().equals("取消置顶")) {
                    action.setActionName("置顶聊天");
                }

            }
        }
        mSessionPopAdapter = new PopMenuAdapter();
        mSessionPopList.setAdapter(mSessionPopAdapter);
        mSessionPopAdapter.setDataSource(mSessionPopActions);
        mSessionPopWindow = PopWindowUtil.popupWindow(itemPop, this, (int) locationX, (int) locationY);
    }

    /**
     * 设置更多弹框的Action,开发者可调用该接口修改默认的更多弹框操作
     *
     * @param actions PopMenuAction集合
     * @param isAdd   是否为添加，ture为在默认的弹框集合上添加新的item,false再替换默认的
     */
    public void setMorePopActions(List<PopMenuAction> actions, boolean isAdd) {
        if (isAdd)
            mMoreActions.addAll(actions);
        else
            mMoreActions = actions;
    }

    /**
     * 设置会话长按弹框的Action,开发者可调用该接口修改默认的会话长按操作
     *
     * @param actions PopMenuAction集合
     * @param isAdd   是否为添加，ture为在默认的弹框集合上添加新的item,false再替换默认的
     */
    public void setSessionPopActions(List<PopMenuAction> actions, boolean isAdd) {
        if (isAdd)
            mSessionPopActions.addAll(actions);
        else
            mSessionPopActions = actions;

    }

    /**
     * 设置会话列表其它事件(除单击事件外)监听器，不设置则用默认实现
     *
     * @param {SessionListEvent} event
     */
    public void setSessionListEvent(SessionListEvent event) {
        this.mSessionEvent = event;
    }


    /**
     * 设置会话面板的Listview的适配器{@link com.tencent.qcloud.uikit.api.session.ISessionAdapter}
     *
     * @param adapter
     */
    @Override
    public void setSessionAdapter(ISessionAdapter adapter) {
        mAdapter = adapter;
        mSessionList.setAdapter(mAdapter);
    }


    /**
     * 获取会话列表的适配器
     *
     * @return
     */
    public ISessionAdapter getSessionAdapter() {
        return mAdapter;
    }


    /**
     * 设置会话列表点击回调事件，控制会话点击时的界面跳转
     *
     * @param clickListener
     */
    @Override
    public void setSessionClick(SessionClickListener clickListener) {
        mSessionClickListener = clickListener;
    }

    /**
     * 数据会话列表
     */
    @Override
    public void refresh() {
        mAdapter.notifyDataSetChanged();
    }


    @Override
    public void setSessionIconInvoke(DynamicSessionIconView informationalView) {
        mInfoView = informationalView;
    }

    public void startChat(SessionInfo sessionInfo) {
        if (mSessionClickListener != null)
            mSessionClickListener.onSessionClick(sessionInfo);
    }

    public DynamicSessionIconView getInfoView() {
        return mInfoView;
    }

    @Override
    public void initDefault() {
        mTitleBar.setTitle("会话", PageTitleBar.POSITION.CENTER);
        mTitleBar.getLeftGroup().setVisibility(View.GONE);
        mTitleBar.getRightIcon().setImageResource(R.drawable.session_more);
        mTitleBar.setRightClick(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mPopMemuDialog != null && mPopMemuDialog.isShowing()) {
                    mPopMemuDialog.dismiss();
                } else {
                    showMorePopMenu();
                }
            }
        });


        List<PopMenuAction> menuActions = new ArrayList<PopMenuAction>();
        PopMenuAction action = new PopMenuAction();
        action.setActionName("发起会话");
        action.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int position, Object data) {
                Intent intent = new Intent(getContext(), C2CChatStartActivity.class);
                getContext().startActivity(intent);
                mPopMemuDialog.dismiss();
            }
        });
        action.setIconResId(R.drawable.session_c2c);
        menuActions.add(action);
        action = new PopMenuAction();
        action.setActionName("创建群聊");
        action.setIconResId(R.drawable.session_group);
        action.setActionClickListener(new PopActionClickListener() {

            @Override
            public void onActionClick(int position, Object data) {
                Intent intent = new Intent(getContext(), GroupChatCreateActivity.class);
                getContext().startActivity(intent);
                mPopMemuDialog.dismiss();
            }
        });
        menuActions.add(action);
        action = new PopMenuAction();
        action.setActionName("加入群聊");
        action.setIconResId(R.drawable.join_group);
        action.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int position, Object data) {
                Intent intent = new Intent(getContext(), GroupChatJoinActivity.class);
                getContext().startActivity(intent);
                mPopMemuDialog.dismiss();
            }
        });
        menuActions.add(action);
        setMorePopActions(menuActions, false);


        List<PopMenuAction> sessionPopActions = new ArrayList<PopMenuAction>();
        action = new PopMenuAction();
        action.setActionName("置顶聊天");
        action.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int position, Object data) {
                mPresenter.setSessionTop(position, (SessionInfo) data);
            }
        });
        sessionPopActions.add(action);
        action = new PopMenuAction();
        action.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int position, Object data) {
                mPresenter.deleteSession(position, (SessionInfo) data);
            }
        });
        action.setActionName("删除聊天");
        sessionPopActions.add(action);
        setSessionPopActions(sessionPopActions, true);


        final SessionAdapter adapter = new SessionAdapter(this);
        adapter.setOnRightItemClickListener(new SessionAdapter.onRightItemClickListener() {
            @Override
            public void onRightItemClick(View v, int position) {
                mPresenter.deleteSession(position, adapter.getItem(position));
                mSessionList.resetState();
            }
        });
        setSessionAdapter(adapter);

       /* setSessionIconInvoke(new DynamicSessionIconView() {
            @Override
            public void parseInformation(SessionInfo info) {
                ImageView img = new ImageView(getContext());
                img.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
                img.setImageResource(R.drawable.message_send_fail);
                RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(UIUtils.getPxByDp(10), UIUtils.getPxByDp(10));
                params.addRule(RelativeLayout.RIGHT_OF, mViewId);
                params.setMargins(-UIUtils.getPxByDp(5), 0, 0, 0);
                addChild(img, params);
            }
        });*/

        mPresenter = new SessionPresenter(this);
        mPresenter.loadSessionData();
    }
}
