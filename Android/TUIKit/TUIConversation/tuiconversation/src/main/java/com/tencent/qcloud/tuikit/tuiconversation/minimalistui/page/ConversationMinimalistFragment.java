package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.page;

import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.action.PopActionClickListener;
import com.tencent.qcloud.tuicore.component.action.PopDialogAdapter;
import com.tencent.qcloud.tuicore.component.action.PopMenuAction;
import com.tencent.qcloud.tuicore.component.fragments.BaseFragment;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationConstants;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.interfaces.OnConversationAdapterListener;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.ConversationUtils;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.util.TUIConversationUtils;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget.ConversationLayout;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget.ConversationListAdapter;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget.Menu;
import com.tencent.qcloud.tuikit.tuiconversation.presenter.ConversationPresenter;

import java.util.ArrayList;
import java.util.List;

public class ConversationMinimalistFragment extends BaseFragment {
    private View mBaseView;
    private ConversationLayout mConversationLayout;
    private ListView mConversationPopList;
    private PopDialogAdapter mConversationPopAdapter;
    private PopupWindow mConversationPopWindow;
    private String popWindowConversationId;
    private List<PopMenuAction> mConversationPopActions = new ArrayList<>();
    private AlertDialog mBottomDialog;
    private boolean isShowReadButton, isShowReadAllButton;
    private BroadcastReceiver unreadCountReceiver;
    private Menu menu;

    private ConversationPresenter presenter;
    private ConversationListAdapter mAdapter;
    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        mBaseView = inflater.inflate(R.layout.minimalistui_conversation_fragment, container, false);
        initView();
        return mBaseView;
    }

    private void initView() {
        // 从布局文件中获取会话列表面板
        mConversationLayout = mBaseView.findViewById(R.id.conversation_layout);

        presenter = new ConversationPresenter();
        presenter.setConversationListener();
        presenter.setShowType(ConversationPresenter.SHOW_TYPE_CONVERSATION_LIST_WITH_FOLD);
        mConversationLayout.setPresenter(presenter);

        // 会话列表面板的默认UI和交互初始化
        mConversationLayout.initDefault();
        // 通过API设置ConversataonLayout各种属性的样例，开发者可以打开注释，体验效果
//        ConversationLayoutSetting.customizeConversation(mConversationLayout);
        isShowReadButton = false;
        isShowReadAllButton = false;
        mAdapter = mConversationLayout.getConversationList().getAdapter();
        mConversationLayout.getConversationList().setOnConversationAdapterListener(new OnConversationAdapterListener() {
            @Override
            public void onItemClick(View view, int viewType, ConversationInfo conversationInfo) {
                if (mConversationLayout.isMultiSelected()) {
                    if (mAdapter == null) {
                        refreshEditConversationDialog(0);
                        return;
                    }
                    List<ConversationInfo> mSelectConversations = mAdapter.getSelectedItem();
                    if (mSelectConversations == null) {
                        refreshEditConversationDialog(0);
                        return;
                    }
                    isShowReadButton = false;
                    for(ConversationInfo conversation : mSelectConversations) {
                        if (conversation.isMarkUnread() || conversation.getUnRead() > 0) {
                            isShowReadButton = true;
                            break;
                        }
                    }

                    refreshEditConversationDialog(mSelectConversations.size());
                } else if (conversationInfo.isMarkFold()) {
                    mConversationLayout.clearUnreadStatusOfFoldItem();
                    startFoldedConversationActivity();
                } else {
                    TUIConversationUtils.startChatActivity(conversationInfo);
                }
            }

            @Override
            public void OnItemLongClick(View view, ConversationInfo conversationInfo) {
                showItemPopMenu(view, conversationInfo);
            }

            @Override
            public void onConversationChanged(List<ConversationInfo> dataSource) {
                if (dataSource == null)return;
                ConversationInfo conversationInfo = dataSource.get(0);
                if (conversationInfo == null)return;

                if (!TextUtils.isEmpty(popWindowConversationId) && popWindowConversationId.equals(conversationInfo.getConversationId())) {
                    if (mConversationPopWindow != null) {
                        mConversationPopWindow.dismiss();
                    }
                    if (mAdapter != null) {
                        mAdapter.closeAllSwipeItems();
                    }
                }
            }

            @Override
            public void onMarkConversationUnread(View view, ConversationInfo conversationInfo, boolean markUnread) {
                mConversationLayout.markConversationUnread(conversationInfo, markUnread);
            }

            @Override
            public void onMarkConversationHidden(View view, ConversationInfo conversationInfo) {
                mConversationLayout.markConversationHidden(conversationInfo);
            }

            @Override
            public void onClickMoreView(View view, ConversationInfo conversationInfo) {
                showConversationMoreActionDialog(conversationInfo);
            }

            @Override
            public void onSwipeConversationChanged(ConversationInfo conversationInfo) {
                if (conversationInfo == null) {
                    popWindowConversationId = "";
                    return;
                }
                popWindowConversationId = conversationInfo.getConversationId();
            }
        });

        mConversationLayout.setOnClickListener(new OnClickListener() {
            @Override
            public void onEditConversationStartClick() {
                showEditConversationDialog();
            }

            @Override
            public void onEditConversationEndClick() {
                closeEditConversationDialog();
            }

            @Override
            public void onStartChatClick() {
                if (menu == null) {
                    return;
                }
                if (menu.isShowing()) {
                    menu.hide();
                } else {
                    menu.show();
                }
            }
        });

        initUnreadCountReceiver();
        restoreConversationItemBackground();
        setConversationMenu();
    }

    public void restoreConversationItemBackground() {
        if (mConversationLayout.getConversationList().getAdapter() !=  null &&
                mConversationLayout.getConversationList().getAdapter().isClick()) {
            mConversationLayout.getConversationList().getAdapter().setClick(false);
            mConversationLayout.getConversationList().getAdapter().notifyItemChanged(mConversationLayout.getConversationList().getAdapter().getCurrentPosition());
        }
    }

    private void initUnreadCountReceiver() {
        unreadCountReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                long unreadCount = intent.getLongExtra(TUIConstants.UNREAD_COUNT_EXTRA, 0);
                if (unreadCount > 0) {
                    isShowReadAllButton = true;
                } else {
                    isShowReadAllButton = false;
                }
            }
        };
        IntentFilter unreadCountFilter = new IntentFilter();
        unreadCountFilter.addAction(TUIConstants.CONVERSATION_UNREAD_COUNT_ACTION);
        LocalBroadcastManager.getInstance(getContext()).registerReceiver(unreadCountReceiver, unreadCountFilter);
    }

    private void initPopMenuAction() {
        // 设置长按conversation显示PopAction
        List<PopMenuAction> conversationPopActions = new ArrayList<PopMenuAction>();
        PopMenuAction action = new PopMenuAction();
        action.setActionName(getResources().getString(R.string.not_display));
        action.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int index, Object data) {
                ConversationInfo conversationInfo = (ConversationInfo) data;
                if (conversationInfo.isMarkFold()) {
                    mConversationLayout.hideFoldedItem(true);
                } else {
                    mConversationLayout.markConversationHidden(conversationInfo);
                }
            }
        });
        conversationPopActions.add(action);

        mConversationPopActions.clear();
        mConversationPopActions.addAll(conversationPopActions);
    }

    private void addMarkUnreadPopMenuAction(boolean markUnread) {
        PopMenuAction action = new PopMenuAction();
        action.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int index, Object data) {
                mConversationLayout.markConversationUnread((ConversationInfo) data, markUnread);
            }
        });
        if (markUnread) {
            action.setActionName(getResources().getString(R.string.mark_unread));
        } else {
            action.setActionName(getResources().getString(R.string.mark_read));
        }
        mConversationPopActions.add(0, action);
    }

    private void addDeletePopMenuAction() {
        PopMenuAction action = new PopMenuAction();
        action.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int index, Object data) {
                mConversationLayout.deleteConversation((ConversationInfo) data);
            }
        });
        action.setActionName(getResources().getString(R.string.chat_delete));
        mConversationPopActions.add(action);
    }

    /**
     * 长按会话item弹框
     * @param view 长按 view
     * @param conversationInfo 会话数据对象
     */
    private void showItemPopMenu(View view, final ConversationInfo conversationInfo) {
        initPopMenuAction();

        if (!conversationInfo.isMarkFold()) {
            if (conversationInfo.getUnRead() > 0) {
                addMarkUnreadPopMenuAction(false);
            } else {
                if (conversationInfo.isMarkUnread()) {
                    addMarkUnreadPopMenuAction(false);
                } else {
                    addMarkUnreadPopMenuAction(true);
                }
            }

            addDeletePopMenuAction();
        }

        View itemPop = LayoutInflater.from(getActivity()).inflate(R.layout.conversation_pop_menu_layout, null);
        mConversationPopList = itemPop.findViewById(R.id.pop_menu_list);
        mConversationPopList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                PopMenuAction action = mConversationPopActions.get(position);
                if (action.getActionClickListener() != null) {
                    action.getActionClickListener().onActionClick(position, conversationInfo);
                }
                mConversationPopWindow.dismiss();
                restoreConversationItemBackground();
            }
        });

        for (int i = 0; i < mConversationPopActions.size(); i++) {
            PopMenuAction action = mConversationPopActions.get(i);
            if (conversationInfo.isTop()) {
                if (action.getActionName().equals(getResources().getString(R.string.chat_top))) {
                    action.setActionName(getResources().getString(R.string.quit_chat_top));
                }
            } else {
                if (action.getActionName().equals(getResources().getString(R.string.quit_chat_top))) {
                    action.setActionName(getResources().getString(R.string.chat_top));
                }

            }
        }
        mConversationPopAdapter = new PopDialogAdapter();
        mConversationPopList.setAdapter(mConversationPopAdapter);
        mConversationPopAdapter.setDataSource(mConversationPopActions);
        mConversationPopWindow = new PopupWindow(itemPop, WindowManager.LayoutParams.WRAP_CONTENT, WindowManager.LayoutParams.WRAP_CONTENT);
        mConversationPopWindow.setBackgroundDrawable(new ColorDrawable());
        mConversationPopWindow.setOutsideTouchable(true);
        popWindowConversationId = conversationInfo.getConversationId();
        int width = ConversationUtils.getListUnspecifiedWidth(mConversationPopAdapter, mConversationPopList);
        mConversationPopWindow.setWidth(width);
        mConversationPopWindow.setOnDismissListener(new PopupWindow.OnDismissListener() {
            @Override
            public void onDismiss() {
                restoreConversationItemBackground();
                popWindowConversationId = "";
            }
        });
        int x = view.getWidth() / 2;
        int y = - view.getHeight() / 3;
        int popHeight = ScreenUtil.dip2px(45) * 3;
        if (y + popHeight + view.getY() + view.getHeight() > mConversationLayout.getBottom()) {
            y = y - popHeight;
        }
        mConversationPopWindow.showAsDropDown(view, x, y, Gravity.TOP | Gravity.START);
    }

    private void startFoldedConversationActivity() {
        Intent intent = new Intent(getActivity(), TUIFoldedConversationMinimalistActivity.class);
        startActivity(intent);
    }

    public interface OnClickListener {
        void onEditConversationStartClick();
        void onEditConversationEndClick();
        void onStartChatClick();
    }

    private void showEditConversationDialog(){
        if (mBottomDialog != null && mBottomDialog.isShowing()) {
            return;
        }
        View view = LayoutInflater.from(getContext()).inflate(R.layout.minimalist_bottom_bar,null,false);
        mBottomDialog = new AlertDialog.Builder(getContext()).setView(view).create();

        TextView markReadView = view.findViewById(R.id.mark_read);
        TextView notDisplayView = view.findViewById(R.id.not_display);
        TextView deleteChatView = view.findViewById(R.id.delete_chat);

        if (isShowReadAllButton) {
            markReadView.setAlpha(1f);
            markReadView.setEnabled(true);
            markReadView.setText(getString(R.string.has_all_read));
        } else {
            markReadView.setAlpha(0.5f);
            markReadView.setEnabled(false);
            markReadView.setText(getString(R.string.mark_read));
        }
        notDisplayView.setAlpha(0.5f);
        notDisplayView.setEnabled(false);
        deleteChatView.setAlpha(0.5f);
        deleteChatView.setEnabled(false);

        markReadView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (markReadView.getText().equals(getString(R.string.has_all_read))) {
                    presenter.clearAllUnreadMessage();
                } else {
                    if (mAdapter == null) {
                        resetEditConversationStatus();
                        return;
                    }
                    List<ConversationInfo> mSelectConversations = mAdapter.getSelectedItem();
                    for (ConversationInfo conversationInfo : mSelectConversations) {
                        mConversationLayout.markConversationUnread(conversationInfo, false);
                    }
                }
                resetEditConversationStatus();
            }
        });

        notDisplayView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mAdapter == null) {
                    resetEditConversationStatus();
                    return;
                }
                List<ConversationInfo> mSelectConversations = mAdapter.getSelectedItem();
                for(ConversationInfo conversationInfo : mSelectConversations) {
                    mConversationLayout.markConversationHidden(conversationInfo);
                }
                resetEditConversationStatus();
            }
        });

        deleteChatView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mAdapter == null) {
                    resetEditConversationStatus();
                    return;
                }
                List<ConversationInfo> mSelectConversations = mAdapter.getSelectedItem();
                for(ConversationInfo conversationInfo : mSelectConversations) {
                    mConversationLayout.deleteConversation(conversationInfo);
                }
                resetEditConversationStatus();
            }
        });

        mBottomDialog.setCanceledOnTouchOutside(false);
        mBottomDialog.show();
        Window win = mBottomDialog.getWindow();
        win.setGravity(Gravity.BOTTOM);   // 这里控制弹出的位置
        win.getDecorView().setPadding(0, 0, 0, 0);
        WindowManager.LayoutParams lp = win.getAttributes();
        lp.width = WindowManager.LayoutParams.MATCH_PARENT;
        lp.height = WindowManager.LayoutParams.WRAP_CONTENT;
        mBottomDialog.getWindow().setBackgroundDrawableResource(R.color.conversation_bottom_bg);
        win.setAttributes(lp);

        win.setDimAmount(0f);
        win.setFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL, WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL);
        win.setFlags(WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH, WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH);

        mBottomDialog.setOnKeyListener(new DialogInterface.OnKeyListener() {
            @Override
            public boolean onKey(DialogInterface dialog, int keyCode, KeyEvent event) {
                if (keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN) {
                    resetEditConversationStatus();
                }
                return false;
            }
        });
    }

    private void refreshEditConversationDialog(int selectSize) {
        if (mBottomDialog == null) {
            return;
        }

        TextView markReadView = mBottomDialog.findViewById(R.id.mark_read);
        TextView notDisplayView = mBottomDialog.findViewById(R.id.not_display);
        TextView deleteChatView = mBottomDialog.findViewById(R.id.delete_chat);

        if (selectSize <= 0) {
            deleteChatView.setAlpha(0.5f);
            deleteChatView.setEnabled(false);

            notDisplayView.setAlpha(0.5f);
            notDisplayView.setEnabled(false);

            markReadView.setAlpha(1f);
            markReadView.setEnabled(true);
            markReadView.setText(getString(R.string.has_all_read));
        } else {
            deleteChatView.setAlpha(1f);
            deleteChatView.setEnabled(true);

            notDisplayView.setAlpha(1f);
            notDisplayView.setEnabled(true);

            markReadView.setText(getString(R.string.mark_read));
            if (isShowReadButton) {
                markReadView.setAlpha(1f);
                markReadView.setEnabled(true);
            } else {
                markReadView.setAlpha(0.5f);
                markReadView.setEnabled(false);
            }
        }
    }

    private void resetEditConversationStatus() {
        isShowReadAllButton = false;
        isShowReadButton = false;
        if (mBottomDialog != null) {
            mBottomDialog.dismiss();
        }
        mConversationLayout.resetTitileBar();
    }

    private void closeEditConversationDialog() {
        if (mBottomDialog != null) {
            mBottomDialog.dismiss();
        }
    }

    private void setConversationMenu() {
        menu = new Menu(getActivity(), mConversationLayout.getCreateChatView());
        PopActionClickListener popActionClickListener = new PopActionClickListener() {
            @Override
            public void onActionClick(int position, Object data) {
                PopMenuAction action = (PopMenuAction) data;
                if (TextUtils.equals(action.getActionName(), getResources().getString(R.string.start_conversation))) {
                    TUICore.startActivity("StartC2CChatMinimalistActivity", null);
                }

                if (TextUtils.equals(action.getActionName(), getResources().getString(R.string.create_group_chat))) {
                    Bundle bundle = new Bundle();
                    bundle.putInt(TUIConversationConstants.GroupType.TYPE, TUIConversationConstants.GroupType.PUBLIC);
                    TUICore.startActivity("StartGroupChatMinimalistActivity", bundle);
                }

                menu.hide();
            }
        };

        List<PopMenuAction> menuActions = new ArrayList<>();

        PopMenuAction action = new PopMenuAction();

        action.setActionName(getResources().getString(R.string.start_conversation));
        action.setActionClickListener(popActionClickListener);
        action.setIconResId(R.drawable.create_c2c);
        menuActions.add(action);

        action = new PopMenuAction();
        action.setActionName(getResources().getString(R.string.create_group_chat));
        action.setIconResId(R.drawable.group_icon);
        action.setActionClickListener(popActionClickListener);
        menuActions.add(action);

        menu.setMenuAction(menuActions);
    }

    private void showConversationMoreActionDialog(ConversationInfo conversationInfo){
        View view = LayoutInflater.from(getContext()).inflate(R.layout.minimalist_more_dialog,null,false);
        AlertDialog moreDialog = new AlertDialog.Builder(getContext()).setView(view).create();

        TextView setTopView = view.findViewById(R.id.top_set);
        TextView notDisplayView = view.findViewById(R.id.not_display);
        TextView clearChatView = view.findViewById(R.id.clear_chat);
        TextView deleteChatView = view.findViewById(R.id.delete_chat);
        TextView cancelView = view.findViewById(R.id.cancel_button);


        if (conversationInfo.isTop()) {
            setTopView.setText(getString(R.string.quit_chat_top));
        } else {
            setTopView.setText(getString(R.string.chat_top));
        }
        setTopView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mConversationLayout.setConversationTop(conversationInfo, new IUIKitCallback() {
                    @Override
                    public void onSuccess(Object data) {
                        super.onSuccess(data);
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        super.onError(module, errCode, errMsg);
                    }
                });
                moreDialog.dismiss();
            }
        });

        notDisplayView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mConversationLayout.markConversationHidden(conversationInfo);
                moreDialog.dismiss();
            }
        });

        clearChatView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mConversationLayout.clearConversationMessage(conversationInfo);
                if (conversationInfo.isMarkUnread()) {
                    mConversationLayout.markConversationUnread(conversationInfo, false);
                }
                moreDialog.dismiss();
            }
        });

        deleteChatView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mConversationLayout.deleteConversation(conversationInfo);
                moreDialog.dismiss();
            }
        });

        cancelView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                moreDialog.dismiss();
            }
        });

        moreDialog.setCanceledOnTouchOutside(false);
        Window win = moreDialog.getWindow();
        WindowManager.LayoutParams lp = win.getAttributes();
        lp.width = lp.width - ScreenUtil.getPxByDp(16f);
        lp.y = ScreenUtil.getPxByDp(34f);
        moreDialog.getWindow().setBackgroundDrawableResource(com.tencent.qcloud.tuicore.R.color.status_bar_color);
        win.setGravity(Gravity.CENTER_HORIZONTAL | Gravity.BOTTOM);
        win.setAttributes(lp);
        moreDialog.show();

        moreDialog.setOnKeyListener(new DialogInterface.OnKeyListener() {
            @Override
            public boolean onKey(DialogInterface dialog, int keyCode, KeyEvent event) {
                if (keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN) {
                    moreDialog.dismiss();
                }
                return false;
            }
        });
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

        if (unreadCountReceiver != null) {
            LocalBroadcastManager.getInstance(getContext()).unregisterReceiver(unreadCountReceiver);
            unreadCountReceiver = null;
        }
    }

}
