package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.page;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuikit.timcommon.component.fragments.BaseFragment;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationConstants;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.interfaces.OnConversationAdapterListener;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget.ConversationListAdapter;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.widget.ForwardSelectLayout;
import com.tencent.qcloud.tuikit.tuiconversation.presenter.ConversationPresenter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class TUIForwardSelectMinimalistFragment extends BaseFragment {
    private static final String TAG = TUIForwardSelectMinimalistFragment.class.getSimpleName();

    private View mBaseView;
    private ForwardSelectLayout mForwardLayout;
    private TextView conversationNamesTv;
    private List<ConversationInfo> mDataSource = new ArrayList<>();
    private View forwardListLayout;
    private TextView mSureView;

    private ConversationPresenter presenter;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        mBaseView = inflater.inflate(R.layout.minimalist_forward_fragment, container, false);
        return mBaseView;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        mForwardLayout = view.findViewById(R.id.forward_conversation_layout);
        conversationNamesTv = view.findViewById(R.id.conversation_name_tv);
        forwardListLayout = view.findViewById(R.id.forward_list_layout);

        presenter = new ConversationPresenter();
        mForwardLayout.setPresenter(presenter);

        mForwardLayout.initDefault();

        mForwardLayout.getConversationList().setOnConversationAdapterListener(new OnConversationAdapterListener() {
            @Override
            public void onItemClick(View view, int viewType, ConversationInfo conversationInfo) {
                refreshSelectConversations();
            }

            @Override
            public void onItemLongClick(View view, ConversationInfo conversationInfo) {}

            @Override
            public void onConversationChanged(List<ConversationInfo> dataSource) {}

            @Override
            public void onMarkConversationUnread(View view, ConversationInfo conversationInfo, boolean markUnread) {}

            @Override
            public void onMarkConversationHidden(View view, ConversationInfo conversationInfo) {}

            @Override
            public void onClickMoreView(View view, ConversationInfo conversationInfo) {}

            @Override
            public void onSwipeConversationChanged(ConversationInfo conversationInfo) {}
        });

        mSureView = view.findViewById(R.id.btn_msg_ok);
        mSureView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (getActivity() != null) {
                    HashMap<String, Boolean> conversationMap = new HashMap<>();
                    if (mDataSource != null && !mDataSource.isEmpty()) {
                        for (int i = 0; i < mDataSource.size(); i++) {
                            conversationMap.put(mDataSource.get(i).getId(), mDataSource.get(i).isGroup());
                        }
                    }

                    Intent intent = new Intent();
                    intent.putExtra(TUIConversationConstants.FORWARD_SELECT_CONVERSATION_KEY, conversationMap);
                    getActivity().setResult(TUIConversationConstants.FORWARD_SELECT_ACTIVTY_CODE, intent);
                    getActivity().finish();
                }
            }
        });

        refreshSelectConversations();
    }

    private void refreshSelectConversations() {
        ConversationListAdapter adapter = mForwardLayout.getConversationList().getAdapter();
        if (adapter != null) {
            mDataSource = adapter.getSelectedItem();
        } else {
            mDataSource = null;
        }

        conversationNamesTv.setText(getSelectedNames());
        if (mDataSource == null || mDataSource.isEmpty()) {
            mSureView.setVisibility(View.GONE);
            forwardListLayout.setVisibility(View.GONE);
        } else {
            forwardListLayout.setVisibility(View.VISIBLE);
            mSureView.setVisibility(View.VISIBLE);
            mSureView.setText(getString(R.string.conversation_forward) + "(" + mDataSource.size() + ")");
        }
    }

    private String getSelectedNames() {
        if (mDataSource == null || mDataSource.isEmpty()) {
            return "";
        }
        StringBuffer stringBuffer = new StringBuffer();
        for (ConversationInfo conversationInfo : mDataSource) {
            stringBuffer.append(conversationInfo.getShowName());
            stringBuffer.append(",");
        }
        return stringBuffer.substring(0, stringBuffer.length() - 1);
    }
}
