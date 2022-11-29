package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.recyclerview.widget.LinearLayoutManager;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.interfaces.IConversationListAdapter;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.interfaces.IConversationLayout;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.page.ConversationMinimalistFragment;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.setting.ConversationLayoutSetting;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget.swipe.Attributes;
import com.tencent.qcloud.tuikit.tuiconversation.presenter.ConversationPresenter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ConversationLayout extends RelativeLayout implements IConversationLayout {

    private ConversationListLayout mConversationList;
    private ViewGroup searchLayout;
    private ConversationPresenter presenter;
    private ImageView conversationEditView, createChatView;
    private TextView conversationEditDoneView;
    private ConversationMinimalistFragment.OnClickListener mClickListener = null;
    private boolean isMultiSelected = false;
    private List<ConversationInfo> mSelectConversations = new ArrayList<>();

    public ConversationLayout(Context context) {
        super(context);
        init();
    }

    public ConversationLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public ConversationLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    public void setPresenter(ConversationPresenter presenter) {
        this.presenter = presenter;
        if (mConversationList != null) {
            mConversationList.setPresenter(presenter);
        }
    }

    /**
     * 初始化相关UI元素
     */
    private void init() {
        inflate(getContext(), R.layout.minimalistui_conversation_layout, this);
        mConversationList = findViewById(R.id.conversation_list);
        searchLayout = findViewById(R.id.search_layout);
        conversationEditView = findViewById(R.id.edit_button);
        createChatView = findViewById(R.id.create_new_button);
        conversationEditDoneView = findViewById(R.id.edit_done);
        mSelectConversations.clear();
        conversationEditView.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mClickListener != null) {
                    mClickListener.onEditConversationStartClick();
                }
                conversationEditView.setVisibility(GONE);
                conversationEditDoneView.setVisibility(VISIBLE);
                createChatView.setVisibility(GONE);

                conversationMutiSelectStart();
            }
        });
        createChatView.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mClickListener != null) {
                    mClickListener.onStartChatClick();
                }
            }
        });
        conversationEditDoneView.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mClickListener != null) {
                    mClickListener.onEditConversationEndClick();
                }
                conversationEditView.setVisibility(VISIBLE);
                conversationEditDoneView.setVisibility(GONE);
                createChatView.setVisibility(VISIBLE);

                conversationMutiSelectEnd();
            }
        });
    }

    public ImageView getCreateChatView() {
        return createChatView;
    }

    public void resetTitileBar() {
        conversationEditView.setVisibility(VISIBLE);
        conversationEditDoneView.setVisibility(GONE);
        createChatView.setVisibility(VISIBLE);
        conversationMutiSelectEnd();
    }

    public void setOnClickListener(ConversationMinimalistFragment.OnClickListener listener) {
        mClickListener = listener;
    }
    public boolean isMultiSelected() {
        return isMultiSelected;
    }

    private void conversationMutiSelectStart() {
        ConversationListAdapter adapter = mConversationList.getAdapter();
        if (adapter != null) {
            adapter.setShowMultiSelectCheckBox(true);
            adapter.notifyDataSetChanged();
            adapter.closeAllSwipeItems();
            adapter.switchAllSwipeEnable(false);
        }
        isMultiSelected = true;
        mSelectConversations.clear();
    }

    private void conversationMutiSelectEnd() {
        ConversationListAdapter adapter = mConversationList.getAdapter();
        if (adapter != null) {
            adapter.setShowMultiSelectCheckBox(false);
            adapter.notifyDataSetChanged();
            adapter.closeAllSwipeItems();
            adapter.switchAllSwipeEnable(true);
        }
        isMultiSelected = false;
        mSelectConversations.clear();
    }

    public void initDefault() {
        final ConversationListAdapter adapter = new ConversationListAdapter();
        if (presenter != null) {
            initSearchView(adapter);
            adapter.setShowFoldedStyle(true);
        }

        mConversationList.setLayoutManager(new LinearLayoutManager(getContext()));
        adapter.setMode(Attributes.Mode.Single);
        mConversationList.setAdapter((IConversationListAdapter) adapter);
        if (presenter != null) {
            presenter.setAdapter(adapter);
        }
        ConversationLayoutSetting.customizeConversation(this);
        mConversationList.loadConversation(0);
    }

    public void initSearchView(ConversationListAdapter adapter) {
        Map<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIConversation.CONTEXT, getContext());
        Map<String, Object> searchExtension = TUICore.getExtensionInfo(TUIConstants.TUIConversation.EXTENSION_MINIMALIST_SEARCH, param);
        if (searchExtension != null) {
            searchLayout.setVisibility(VISIBLE);
            if (searchLayout.getChildCount() == 0) {
                View searchView = (View) searchExtension.get(TUIConstants.TUIConversation.SEARCH_VIEW);
                searchLayout.addView(searchView);
            }
        } else {
            searchLayout.removeAllViews();
            searchLayout.setVisibility(GONE);
        }
    }

    @Override
    public void setParentLayout(Object parent) {

    }

    @Override
    public ConversationListLayout getConversationList() {
        return mConversationList;
    }

    @Override
    public void setConversationTop(ConversationInfo conversation, IUIKitCallback callBack) {
        if (presenter != null) {
            presenter.setConversationTop(conversation, callBack);
        }
    }

    @Override
    public void deleteConversation(ConversationInfo conversation) {
        if (presenter != null) {
            presenter.deleteConversation(conversation);
        }
    }

    @Override
    public void clearConversationMessage(ConversationInfo conversation) {
        if (presenter != null) {
            presenter.clearConversationMessage(conversation);
        }
    }

    @Override
    public void markConversationHidden(ConversationInfo conversation) {
        if (presenter != null) {
            presenter.markConversationHidden(conversation, true);
        }
    }

    @Override
    public void markConversationUnread(ConversationInfo conversationInfo, boolean markUnread) {
        if (presenter != null) {
            presenter.markConversationUnread(conversationInfo, markUnread);
        }
    }

    @Override
    public void hideFoldedItem(boolean needHide) {
        if (presenter != null) {
            presenter.hideFoldItem(needHide);
        }
    }

    @Override
    public void clearUnreadStatusOfFoldItem() {
        if (presenter != null) {
            presenter.setUnreadStatusOfFoldItem(false);
        }
    }

    @Override
    public TitleBarLayout getTitleBar() {
        return null;
    }
}
