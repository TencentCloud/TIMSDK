package com.tencent.qcloud.tuikit.tuiconversation.classicui.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.RelativeLayout;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.classicui.interfaces.IConversationLayout;
import com.tencent.qcloud.tuikit.tuiconversation.interfaces.IConversationListAdapter;
import com.tencent.qcloud.tuikit.tuiconversation.presenter.ConversationPresenter;

public class ForwardSelectLayout extends RelativeLayout implements IConversationLayout {
    private TitleBarLayout titleBarLayout;
    private ConversationListLayout conversationList;
    private ConversationPresenter presenter;

    public ForwardSelectLayout(Context context) {
        super(context);
        init();
    }

    public ForwardSelectLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public ForwardSelectLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    public void setPresenter(ConversationPresenter presenter) {
        this.presenter = presenter;
        if (conversationList != null) {
            conversationList.setPresenter(presenter);
        }
    }

    /**
     * 初始化相关UI元素
     */
    private void init() {
        inflate(getContext(), R.layout.forward_layout, this);
        titleBarLayout = findViewById(R.id.conversation_title);
        conversationList = findViewById(R.id.conversation_list);
    }

    public void initDefault() {
        final ConversationListAdapter adapter = new ConversationListAdapter();
        adapter.setForwardFragment(true);
        conversationList.setAdapter((IConversationListAdapter) adapter);
        presenter.setAdapter(adapter);
        presenter.loadMoreConversation();
    }

    public TitleBarLayout getTitleBar() {
        return titleBarLayout;
    }

    @Override
    public void setParentLayout(Object parent) {}

    @Override
    public ConversationListLayout getConversationList() {
        return conversationList;
    }

    @Override
    public void setConversationTop(ConversationInfo conversation, IUIKitCallback callBack) {}

    @Override
    public void deleteConversation(ConversationInfo conversation) {}

    @Override
    public void clearConversationMessage(ConversationInfo conversation) {}

    @Override
    public void markConversationHidden(ConversationInfo conversation) {}

    @Override
    public void hideFoldedItem(boolean needHide) {}

    @Override
    public void clearUnreadStatusOfFoldItem() {}

    @Override
    public void markConversationUnread(ConversationInfo conversationInfo, boolean markRead) {}
}
