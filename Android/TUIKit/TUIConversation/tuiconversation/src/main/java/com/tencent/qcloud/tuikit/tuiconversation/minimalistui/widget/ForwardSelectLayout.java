package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget;

import android.app.Activity;
import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.interfaces.IConversationListAdapter;
import com.tencent.qcloud.tuikit.tuiconversation.presenter.ConversationPresenter;

public class ForwardSelectLayout extends RelativeLayout {
    private ConversationListLayout conversationList;
    private ConversationPresenter presenter;
    private TextView cancelButton;

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
        inflate(getContext(), R.layout.minimalist_forward_layout, this);
        conversationList = findViewById(R.id.conversation_list);
        cancelButton = findViewById(R.id.cancel_button);
        cancelButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                ((Activity) getContext()).finish();
            }
        });
    }

    public void initDefault() {
        final ConversationListAdapter adapter = new ConversationListAdapter();
        adapter.setForwardFragment(true);
        adapter.setShowMultiSelectCheckBox(true);
        adapter.setSwipeEnabled(false);
        conversationList.setAdapter((IConversationListAdapter) adapter);
        conversationList.setItemAvatarRadius(ScreenUtil.dip2px(28));
        presenter.setAdapter(adapter);
        presenter.loadMoreConversation();
    }

    public ConversationListLayout getConversationList() {
        return conversationList;
    }
}
