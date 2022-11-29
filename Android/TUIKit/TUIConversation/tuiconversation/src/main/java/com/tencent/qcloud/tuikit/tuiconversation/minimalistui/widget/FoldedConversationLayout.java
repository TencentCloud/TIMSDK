package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.RelativeLayout;

import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.interfaces.IConversationListAdapter;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.interfaces.IConversationLayout;
import com.tencent.qcloud.tuikit.tuiconversation.presenter.ConversationFoldPresenter;

public class FoldedConversationLayout extends RelativeLayout implements IConversationLayout {
    private TitleBarLayout titleBarLayout;
    private FoldedConversationListLayout conversationListLayout;
    private ConversationFoldPresenter presenter;

    public FoldedConversationLayout(Context context) {
        super(context);
        init();
    }

    public FoldedConversationLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public FoldedConversationLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    public void setPresenter(ConversationFoldPresenter presenter) {
        this.presenter = presenter;
        if (conversationListLayout != null) {
            conversationListLayout.setPresenter(presenter);
        }
    }

    private void init() {
        inflate(getContext(), R.layout.minimalist_folded_layout, this);
        titleBarLayout = findViewById(R.id.conversation_title);
        conversationListLayout = findViewById(R.id.folded_conversation_list);
    }

    public void initDefault() {
        final ConversationListAdapter adapter = new ConversationListAdapter();
        conversationListLayout.setAdapter((IConversationListAdapter) adapter);
        adapter.setShowFoldedStyle(false);
        if (presenter != null) {
            presenter.setAdapter(adapter);
        }
        conversationListLayout.loadConversation();
    }

    @Override
    public FoldedConversationListLayout getConversationList() {
        return conversationListLayout;
    }

    @Override
    public void setConversationTop(ConversationInfo conversation, IUIKitCallback callBack) {
    }

    @Override
    public void deleteConversation(ConversationInfo conversation) {
        if (presenter != null) {
            presenter.deleteConversation(conversation);
        }
    }

    @Override
    public void clearConversationMessage(ConversationInfo conversation) {

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
        
    }

    @Override
    public void clearUnreadStatusOfFoldItem() {

    }

    @Override
    public TitleBarLayout getTitleBar() {
        return titleBarLayout;
    }

    @Override
    public void setParentLayout(Object parent) {

    }
}
