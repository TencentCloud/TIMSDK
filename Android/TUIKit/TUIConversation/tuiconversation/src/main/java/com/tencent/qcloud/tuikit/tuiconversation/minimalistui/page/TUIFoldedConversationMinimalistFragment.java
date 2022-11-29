package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.page;

import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.PopupWindow;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.action.PopActionClickListener;
import com.tencent.qcloud.tuicore.component.action.PopDialogAdapter;
import com.tencent.qcloud.tuicore.component.action.PopMenuAction;
import com.tencent.qcloud.tuicore.component.fragments.BaseFragment;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.ConversationUtils;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.interfaces.OnConversationAdapterListener;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.util.TUIConversationUtils;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget.FoldedConversationLayout;
import com.tencent.qcloud.tuikit.tuiconversation.presenter.ConversationFoldPresenter;

import java.util.ArrayList;
import java.util.List;

public class TUIFoldedConversationMinimalistFragment extends BaseFragment {
    private View mBaseView;
    private TitleBarLayout mTitleBarLayout;
    private FoldedConversationLayout mFoldedLayout;
    private PopDialogAdapter mConversationPopAdapter;
    private ListView mConversationPopList;
    private PopupWindow mConversationPopWindow;
    private String popWindowConversationId;
    private List<PopMenuAction> mConversationPopActions = new ArrayList<>();

    private ConversationFoldPresenter presenter;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        mBaseView = inflater.inflate(R.layout.minimalist_folded_fragment, container, false);
        initView();
        return mBaseView;
    }

    private void initView() {
        mFoldedLayout = mBaseView.findViewById(R.id.folded_conversation_layout);
        mTitleBarLayout = mFoldedLayout.getTitleBar();
        mTitleBarLayout.setTitle(getResources().getString(R.string.folded_group_chat), ITitleBarLayout.Position.MIDDLE);
        mTitleBarLayout.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getActivity().finish();
            }
        });

        presenter = new ConversationFoldPresenter();
        presenter.initListener();

        mFoldedLayout.setPresenter(presenter);
        mFoldedLayout.initDefault();

        mFoldedLayout.getConversationList().setOnConversationAdapterListener(new OnConversationAdapterListener() {
            @Override
            public void onItemClick(View view, int viewType, ConversationInfo conversationInfo) {
                TUIConversationUtils.startChatActivity(conversationInfo);
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
                }
            }

            @Override
            public void onMarkConversationUnread(View view, ConversationInfo conversationInfo, boolean markUnread) {

            }

            @Override
            public void onMarkConversationHidden(View view, ConversationInfo conversationInfo) {

            }

            @Override
            public void onClickMoreView(View view, ConversationInfo conversationInfo) {

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

        restoreConversationItemBackground();
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
                mFoldedLayout.markConversationHidden((ConversationInfo) data);
            }
        });
        conversationPopActions.add(action);

        action = new PopMenuAction();
        action.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int index, Object data) {
                mFoldedLayout.deleteConversation((ConversationInfo) data);
            }
        });
        action.setActionName(getResources().getString(R.string.chat_delete));
        conversationPopActions.add(action);

        mConversationPopActions.clear();
        mConversationPopActions.addAll(conversationPopActions);
    }

    private void restoreConversationItemBackground() {
        if (mFoldedLayout.getConversationList().getAdapter() !=  null &&
                mFoldedLayout.getConversationList().getAdapter().isClick()) {
            mFoldedLayout.getConversationList().getAdapter().setClick(false);
            mFoldedLayout.getConversationList().getAdapter().notifyItemChanged(mFoldedLayout.getConversationList().getAdapter().getCurrentPosition());
        }
    }

    private void addMarkUnreadPopMenuAction(boolean markUnread) {
        PopMenuAction action = new PopMenuAction();
        action.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int index, Object data) {
                mFoldedLayout.markConversationUnread((ConversationInfo) data, markUnread);
            }
        });
        if (markUnread) {
            action.setActionName(getResources().getString(R.string.mark_unread));
        } else {
            action.setActionName(getResources().getString(R.string.mark_read));
        }
        mConversationPopActions.add(0, action);
    }

    private void showItemPopMenu(View view, final ConversationInfo conversationInfo) {
        initPopMenuAction();

        if (conversationInfo.getUnRead() > 0) {
            addMarkUnreadPopMenuAction(false);
        } else {
            if (conversationInfo.isMarkUnread()) {
                addMarkUnreadPopMenuAction(false);
            } else {
                addMarkUnreadPopMenuAction(true);
            }
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
        if (y + popHeight + view.getY() + view.getHeight() > mFoldedLayout.getBottom()) {
            y = y - popHeight;
        }
        mConversationPopWindow.showAsDropDown(view, x, y, Gravity.TOP | Gravity.START);
    }
}
