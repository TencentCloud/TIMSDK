package com.tencent.qcloud.tuikit.tuiconversation.classicui.page;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.fragments.BaseFragment;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationConstants;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuikit.tuiconversation.classicui.interfaces.OnConversationAdapterListener;
import com.tencent.qcloud.tuikit.tuiconversation.classicui.widget.ConversationListLayout;
import com.tencent.qcloud.tuikit.tuiconversation.classicui.widget.ForwardConversationSelectorAdapter;
import com.tencent.qcloud.tuikit.tuiconversation.classicui.widget.ForwardSelectLayout;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.TUIConversationLog;
import com.tencent.qcloud.tuikit.tuiconversation.presenter.ConversationPresenter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class TUIForwardSelectFragment extends BaseFragment {

    private View mBaseView;
    private TitleBarLayout mTitleBarLayout;
    private ForwardSelectLayout mForwardLayout;

    private RecyclerView mForwardSelectlistView;
    private ForwardConversationSelectorAdapter mAdapter;
    private List<ConversationInfo> mDataSource = new ArrayList<>();
    private List<ConversationInfo> mContactDataSource = new ArrayList<>();
    private List<ConversationInfo> mAllSelectedConversations = new ArrayList<>();
    private RelativeLayout mForwardSelectlistViewLayout;
    private TextView mSureView;

    private ConversationPresenter presenter;

    private static final String TAG = TUIForwardSelectFragment.class.getSimpleName();

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        mBaseView = inflater.inflate(R.layout.forward_fragment, container, false);
        return mBaseView;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        mForwardLayout = view.findViewById(R.id.forward_conversation_layout);

        presenter = new ConversationPresenter();
        mForwardLayout.setPresenter(presenter);

        mForwardLayout.initDefault();

        customizeConversation();
        mForwardLayout.getConversationList().setOnConversationAdapterListener(new OnConversationAdapterListener() {
            @Override
            public void onItemClick(View view, int viewType, ConversationInfo conversationInfo) {
                if (viewType == ConversationInfo.TYPE_RECENT_LABEL){
                    return;
                } else if (viewType == ConversationInfo.TYPE_FORWAR_SELECT){
                    if(mTitleBarLayout.getLeftTitle().getText().equals(getString(R.string.titlebar_cancle))){
                        Bundle param = new Bundle();
                        param.putInt(TUIConversationConstants.GroupType.TYPE, TUIConversationConstants.GroupType.PUBLIC);
                        param.putBoolean(TUIConversationConstants.FORWARD_CREATE_NEW_CHAT, false);
                        TUICore.startActivity(TUIForwardSelectFragment.this, "ForwardSelectGroupActivity", param, TUIConversationConstants.FORWARD_SELECT_MEMBERS_CODE);
                    }else if(mTitleBarLayout.getLeftTitle().getText().equals(getString(R.string.titlebar_close))){
                        Bundle param = new Bundle();
                        param.putInt(TUIConversationConstants.GroupType.TYPE, TUIConversationConstants.GroupType.PUBLIC);
                        param.putBoolean(TUIConversationConstants.FORWARD_CREATE_NEW_CHAT, true);
                        TUICore.startActivity(TUIForwardSelectFragment.this, "ForwardSelectGroupActivity", param, TUIConversationConstants.FORWARD_CREATE_GROUP_CODE);
                    }else{
                        TUIConversationLog.d(TAG,"Titlebar exception");
                    }
                } else {
                    if(mTitleBarLayout.getLeftTitle().getText().equals(getString(R.string.titlebar_cancle))) {
                        mDataSource = mForwardLayout.getConversationList().getAdapter().getSelectedItem();
                        checkRepeat();
                        refreshSelectConversations();
                    } else if(mTitleBarLayout.getLeftTitle().getText().equals(getString(R.string.titlebar_close))){
                        forwardMessages(conversationInfo);
                    } else {
                        forwardMessages(conversationInfo);
                    }
                }
            }

            @Override
            public void OnItemLongClick(View view, ConversationInfo conversationInfo) {

            }

            @Override
            public void onConversationChanged(List<ConversationInfo> dataSource) {

            }
        });

        mForwardSelectlistViewLayout = view.findViewById(R.id.forward_select_list_layout);
        mForwardSelectlistViewLayout.setVisibility(View.VISIBLE);
        mForwardSelectlistView = view.findViewById(R.id.forward_select_list);
        mForwardSelectlistView.setLayoutManager(new CustomLinearLayoutManager(getContext(), CustomLinearLayoutManager.HORIZONTAL, false));
        mAdapter = new ForwardConversationSelectorAdapter(this.getContext());
        mForwardSelectlistView.setAdapter(mAdapter);

        mAdapter.setOnItemClickListener(new ForwardConversationSelectorAdapter.OnItemClickListener() {
            @Override
            public void onClick(View view, int position) {
                boolean needFresh = false;
                if (mDataSource != null && mDataSource.size() != 0){
                    if(position < mDataSource.size()) {
                        mDataSource.remove(position);
                        mForwardLayout.getConversationList().getAdapter().setSelectConversations(mDataSource);
                        needFresh = true;
                    }
                }

                if(!needFresh) {
                    if (mContactDataSource != null && mContactDataSource.size() != 0) {
                        int dataSourcePosition = mDataSource == null ? 0 : mDataSource.size();
                        if (position - dataSourcePosition < mContactDataSource.size()) {
                            mContactDataSource.remove(position - dataSourcePosition);
                            needFresh = true;
                        }
                    }
                }

                if (needFresh) {
                    refreshSelectConversations();
                }
            }
        });
        mSureView = view.findViewById(R.id.btn_msg_ok);
        mSureView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (getActivity() != null) {
                    HashMap<String, Boolean> conversationMap = new HashMap<>();
                    if (mDataSource != null && mDataSource.size() != 0){
                        for (int i=0;i<mDataSource.size();i++){
                            conversationMap.put(mDataSource.get(i).getId(), mDataSource.get(i).isGroup());
                        }
                    }

                    if (mContactDataSource != null && mContactDataSource.size() != 0){
                        for (int i=0;i<mContactDataSource.size();i++){
                            conversationMap.put(mContactDataSource.get(i).getId(), mContactDataSource.get(i).isGroup());
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
        initTitleAction();
    }

    private void refreshSelectConversations(){
        mAllSelectedConversations.clear();

        mDataSource = mForwardLayout.getConversationList().getAdapter().getSelectedItem();

        if (mDataSource != null && mDataSource.size() != 0){
            mAllSelectedConversations.addAll(mDataSource);
        }
        if (mContactDataSource != null && mContactDataSource.size() != 0){
            mAllSelectedConversations.addAll(mContactDataSource);
        }

        mAdapter.setDataSource(mAllSelectedConversations);

        if (mAllSelectedConversations == null || mAllSelectedConversations.size() == 0){
            mSureView.setText(getString(com.tencent.qcloud.tuicore.R.string.sure));
            mSureView.setVisibility(View.GONE);
            mForwardSelectlistViewLayout.setVisibility(View.GONE);
        } else {
            mForwardSelectlistViewLayout.setVisibility(View.VISIBLE);
            mSureView.setVisibility(View.VISIBLE);
            mSureView.setText(getString(com.tencent.qcloud.tuicore.R.string.sure) + "(" + mAllSelectedConversations.size() + ")");
        }
    }

    private void forwardMessages(final ConversationInfo conversationInfo){
        AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
        builder.setTitle("");
        builder.setMessage(getString(R.string.forward_alert_title));
        builder.setCancelable(true);
        builder.setPositiveButton(getString(com.tencent.qcloud.tuicore.R.string.sure), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if (getActivity() != null) {
                    HashMap<String, Boolean> chatInfo = new HashMap<>();
                    chatInfo.put(conversationInfo.getId(), conversationInfo.isGroup());

                    Intent intent = new Intent();
                    intent.putExtra(TUIConversationConstants.FORWARD_SELECT_CONVERSATION_KEY, chatInfo);
                    getActivity().setResult(TUIConversationConstants.FORWARD_SELECT_ACTIVTY_CODE, intent);

                    getActivity().finish();
                }
                dialog.dismiss();
            }
        });
        builder.setNegativeButton(getString(com.tencent.qcloud.tuicore.R.string.cancel), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
            }
        });
        AlertDialog dialog = builder.create();
        dialog.show();
    }

    private void customizeConversation(){
        mTitleBarLayout = mForwardLayout.getTitleBar();
        mTitleBarLayout.setTitle("", TitleBarLayout.Position.MIDDLE);
        mTitleBarLayout.getLeftGroup().setVisibility(View.VISIBLE);
        mTitleBarLayout.getRightGroup().setVisibility(View.VISIBLE);
        mTitleBarLayout.setTitle(getString(R.string.titlebar_close), ITitleBarLayout.Position.LEFT);
        mTitleBarLayout.setTitle(getString(R.string.titlebar_mutiselect), TitleBarLayout.Position.RIGHT);
        mTitleBarLayout.getLeftIcon().setVisibility(View.GONE);
        mTitleBarLayout.getRightIcon().setVisibility(View.GONE);

    }

    private void initTitleAction() {
        mForwardLayout.getTitleBar().setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(mTitleBarLayout.getLeftTitle().getText().equals(getString(R.string.titlebar_cancle))){
                    mTitleBarLayout.getRightGroup().setVisibility(View.VISIBLE);
                    mTitleBarLayout.setTitle(getString(R.string.titlebar_close), TitleBarLayout.Position.LEFT);
                    mTitleBarLayout.setTitle(getString(R.string.titlebar_mutiselect), TitleBarLayout.Position.RIGHT);

                    ConversationListLayout listLayout = mForwardLayout.getConversationList();
                    listLayout.getAdapter().setShowMultiSelectCheckBox(false);
                    listLayout.getAdapter().notifyDataSetChanged();

                    mForwardSelectlistViewLayout.setVisibility(View.GONE);
                    mAdapter.setDataSource(null);
                    mAllSelectedConversations.clear();
                }else if(mTitleBarLayout.getLeftTitle().getText().equals(getString(R.string.titlebar_close))){
                    getActivity().finish();
                }else{
                    TUIConversationLog.d(TAG,"Titlebar exception");
                }
            }
        });

        mForwardLayout.getTitleBar().setOnRightClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mTitleBarLayout.getRightGroup().setVisibility(View.GONE);
                mTitleBarLayout.setTitle(getString(R.string.titlebar_cancle), TitleBarLayout.Position.LEFT);

                ConversationListLayout listLayout = mForwardLayout.getConversationList();
                listLayout.getAdapter().setShowMultiSelectCheckBox(true);
                listLayout.getAdapter().notifyDataSetChanged();
            }
        });
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == TUIConversationConstants.FORWARD_CREATE_GROUP_CODE && resultCode == TUIConversationConstants.FORWARD_CREATE_GROUP_CODE) {
            if (getActivity() != null) {
                getActivity().setResult(TUIConversationConstants.FORWARD_SELECT_ACTIVTY_CODE, data);
                getActivity().finish();
            }
        } else if (requestCode == TUIConversationConstants.FORWARD_SELECT_MEMBERS_CODE && resultCode == TUIConversationConstants.FORWARD_SELECT_MEMBERS_CODE){
            HashMap<String, String> conversationMap = (HashMap<String, String>) data.getSerializableExtra(TUIConversationConstants.FORWARD_SELECT_CONVERSATION_KEY);
            if (conversationMap == null || conversationMap.isEmpty()){
                mContactDataSource.clear();
                refreshSelectConversations();
                return;
            }

            mContactDataSource.clear();
            for (Map.Entry<String, String> entry: conversationMap.entrySet()){
                ConversationInfo conversationInfo = new ConversationInfo();
                List<Object> iconList = new ArrayList<>();
                iconList.add(entry.getValue());
                conversationInfo.setIconUrlList(iconList);
                conversationInfo.setId(entry.getKey());
                conversationInfo.setGroup(false);
                mContactDataSource.add(conversationInfo);
            }
            checkRepeat();

            refreshSelectConversations();
        }
    }

    private void checkRepeat() {
        Iterator<ConversationInfo> iterator = mContactDataSource.iterator();
        while (iterator.hasNext()) {
            ConversationInfo conversationInfo = iterator.next();
            if (mDataSource != null && mDataSource.size() != 0) {
                for (int i = 0; i < mDataSource.size(); i++) {
                    if (conversationInfo.getId().equals(mDataSource.get(i).getId())) {
                        iterator.remove();
                        break;
                    }
                }
            }
        }
    }

}
