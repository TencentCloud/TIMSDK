package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.page;

import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.timcommon.component.action.PopActionClickListener;
import com.tencent.qcloud.tuikit.timcommon.component.action.PopMenuAction;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationConstants;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationPopMenuItem;
import com.tencent.qcloud.tuikit.tuiconversation.config.minimalistui.TUIConversationConfigMinimalist;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.interfaces.OnConversationAdapterListener;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.util.TUIConversationUtils;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget.ConversationLayout;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget.ConversationListAdapter;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget.Menu;
import com.tencent.qcloud.tuikit.tuiconversation.presenter.ConversationPresenter;
import java.util.ArrayList;
import java.util.List;

public class TUIConversationMinimalistFragment extends Fragment {
    private View mBaseView;
    private ConversationLayout mConversationLayout;
    private AlertDialog mBottomDialog;
    private boolean isShowReadButton;
    private boolean isShowReadAllButton;
    private BroadcastReceiver unreadCountReceiver;
    private Menu menu;

    private ConversationPresenter presenter;
    private ConversationListAdapter mAdapter;
    private String title;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        mBaseView = inflater.inflate(R.layout.minimalistui_conversation_fragment, container, false);
        initView();
        return mBaseView;
    }

    @Override
    public void onResume() {
        super.onResume();
        mConversationLayout.initUI();
    }

    private void initView() {
        mConversationLayout = mBaseView.findViewById(R.id.conversation_layout);

        presenter = new ConversationPresenter();
        presenter.setConversationListener();
        presenter.setShowType(ConversationPresenter.SHOW_TYPE_CONVERSATION_LIST_WITH_FOLD);
        mConversationLayout.setPresenter(presenter);

        mConversationLayout.initDefault();
        if (!TextUtils.isEmpty(title)) {
            mConversationLayout.setTitle(title);
        }

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
                    for (ConversationInfo conversation : mSelectConversations) {
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
            public void onItemLongClick(View view, ConversationInfo conversationInfo) {}

            @Override
            public void onConversationChanged(List<ConversationInfo> dataSource) {}

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
            public void onSwipeConversationChanged(ConversationInfo conversationInfo) {}
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

            @Override
            public void finishActivity() {
                getActivity().finish();
            }
        });

        initUnreadCountReceiver();
        restoreConversationItemBackground();
        setConversationMenu();
    }

    public void restoreConversationItemBackground() {
        if (mConversationLayout.getConversationList().getAdapter() != null && mConversationLayout.getConversationList().getAdapter().isClick()) {
            mConversationLayout.getConversationList().getAdapter().setClick(false);
            mConversationLayout.getConversationList().getAdapter().notifyItemChanged(
                mConversationLayout.getConversationList().getAdapter().getCurrentPosition());
        }
    }

    public void setConversationTitle(String title) {
        if (!TextUtils.isEmpty(title)) {
            this.title = title;
            if (mConversationLayout != null) {
                mConversationLayout.setTitle(title);
            }
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

    private void startFoldedConversationActivity() {
        Intent intent = new Intent(getActivity(), TUIFoldedConversationMinimalistActivity.class);
        startActivity(intent);
    }

    public interface OnClickListener {
        void onEditConversationStartClick();

        void onEditConversationEndClick();

        void onStartChatClick();

        void finishActivity();
    }

    private void showEditConversationDialog() {
        if (mBottomDialog != null && mBottomDialog.isShowing()) {
            return;
        }
        View view = LayoutInflater.from(getContext()).inflate(R.layout.minimalist_bottom_bar, null, false);
        mBottomDialog = new AlertDialog.Builder(getContext()).setView(view).create();

        TextView markReadView = view.findViewById(R.id.mark_read);
        TextView notDisplayView = view.findViewById(R.id.not_display);

        if (isShowReadAllButton) {
            markReadView.setAlpha(1f);
            markReadView.setEnabled(true);
            markReadView.setText(getString(R.string.has_all_read));
        } else {
            markReadView.setAlpha(0.5f);
            markReadView.setEnabled(false);
            markReadView.setText(getString(R.string.mark_read));
        }
        TextView deleteChatView = view.findViewById(R.id.delete_chat);
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
                for (ConversationInfo conversationInfo : mSelectConversations) {
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
                for (ConversationInfo conversationInfo : mSelectConversations) {
                    mConversationLayout.deleteConversation(conversationInfo);
                }
                resetEditConversationStatus();
            }
        });

        mBottomDialog.setCanceledOnTouchOutside(false);
        mBottomDialog.show();
        Window win = mBottomDialog.getWindow();
        win.setGravity(Gravity.BOTTOM);
        win.getDecorView().setPaddingRelative(0, 0, 0, 0);
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
        mConversationLayout.resetTitleBar();
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

        PopMenuAction action = new PopMenuAction();

        action.setActionName(getResources().getString(R.string.start_conversation));
        action.setActionClickListener(popActionClickListener);
        action.setIconResId(R.drawable.conversation_create_c2c);
        List<PopMenuAction> menuActions = new ArrayList<>();
        menuActions.add(action);

        action = new PopMenuAction();
        action.setActionName(getResources().getString(R.string.create_group_chat));
        action.setIconResId(R.drawable.conversation_group_icon);
        action.setActionClickListener(popActionClickListener);
        menuActions.add(action);

        menu.setMenuAction(menuActions);
    }

    private void showConversationMoreActionDialog(ConversationInfo conversationInfo) {
        View view = LayoutInflater.from(getContext()).inflate(R.layout.minimalist_more_dialog, null, false);
        LinearLayout layout = view.findViewById(R.id.layout_actions);
        AlertDialog moreDialog = new AlertDialog.Builder(getContext()).setView(view).create();

        List<ConversationPopMenuItem> itemList = getConversationPopMenuItems(conversationInfo, moreDialog);

        for (ConversationPopMenuItem item : itemList) {
            View itemView = LayoutInflater.from(getContext()).inflate(R.layout.conversation_minimalist_pop_menu_item, null, false);
            TextView textView = itemView.findViewById(R.id.text);
            View divider = itemView.findViewById(R.id.divider);
            textView.setText(item.text);
            if (item.isAlert) {
                textView.setTextColor(0xFFFF584C);
            }
            itemView.setOnClickListener(item.onClickListener);
            if (itemList.indexOf(item) == itemList.size() - 1) {
                divider.setVisibility(View.GONE);
            }
            layout.addView(itemView);
        }

        TextView cancelView = view.findViewById(R.id.cancel_button);
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
        moreDialog.getWindow().setBackgroundDrawableResource(com.tencent.qcloud.tuikit.timcommon.R.color.status_bar_color);
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

    @NonNull
    private List<ConversationPopMenuItem> getConversationPopMenuItems(ConversationInfo conversationInfo, AlertDialog moreDialog) {
        List<ConversationPopMenuItem> itemList = new ArrayList<>();
        ConversationPopMenuItem pinItem = new ConversationPopMenuItem();
        if (conversationInfo.isTop()) {
            pinItem.text = getString(R.string.quit_chat_top);
        } else {
            pinItem.text = getString(R.string.chat_top);
        }
        pinItem.onClickListener = new View.OnClickListener() {
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
        };
        itemList.add(pinItem);

        ConversationPopMenuItem hideItem = new ConversationPopMenuItem();
        hideItem.text = getString(R.string.not_display);
        hideItem.onClickListener = new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mConversationLayout.markConversationHidden(conversationInfo);
                moreDialog.dismiss();
            }
        };
        itemList.add(hideItem);
        ConversationPopMenuItem clearHistoryItem = new ConversationPopMenuItem();
        clearHistoryItem.text = getString(R.string.clear_message);
        clearHistoryItem.onClickListener = new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mConversationLayout.clearConversationMessage(conversationInfo);
                if (conversationInfo.isMarkUnread()) {
                    mConversationLayout.markConversationUnread(conversationInfo, false);
                }
                moreDialog.dismiss();
            }
        };
        itemList.add(clearHistoryItem);
        ConversationPopMenuItem deleteItem = new ConversationPopMenuItem();
        deleteItem.text = getString(R.string.chat_delete);
        deleteItem.isAlert = true;
        deleteItem.onClickListener = new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mConversationLayout.deleteConversation(conversationInfo);
                moreDialog.dismiss();
            }
        };
        itemList.add(deleteItem);

        TUIConversationConfigMinimalist.ConversationMenuItemDataSource dataSource = TUIConversationConfigMinimalist.getConversationMenuItemDataSource();
        if (dataSource != null) {
            List<Integer> excludeList = dataSource.conversationShouldHideItemsInMoreMenu(conversationInfo);
            if (excludeList != null && !excludeList.isEmpty()) {
                if (excludeList.contains(TUIConversationConfigMinimalist.PIN)) {
                    itemList.remove(pinItem);
                }
                if (excludeList.contains(TUIConversationConfigMinimalist.HIDE)) {
                    itemList.remove(hideItem);
                }
                if (excludeList.contains(TUIConversationConfigMinimalist.CLEAR)) {
                    itemList.remove(clearHistoryItem);
                }
                if (excludeList.contains(TUIConversationConfigMinimalist.DELETE)) {
                    itemList.remove(deleteItem);
                }
            }
            List<ConversationPopMenuItem> conversationPopMenuItems = dataSource.conversationShouldAddNewItemsToMoreMenu(conversationInfo);
            if (conversationPopMenuItems != null && !conversationPopMenuItems.isEmpty()) {
                itemList.addAll(conversationPopMenuItems);
            }
        }
        return itemList;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

        if (unreadCountReceiver != null) {
            LocalBroadcastManager.getInstance(getContext()).unregisterReceiver(unreadCountReceiver);
            unreadCountReceiver = null;
        }

        if (presenter != null) {
            presenter.destroy();
            presenter = null;
        }
    }
}
