package com.tencent.qcloud.uikit.business.chat.group.view;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.api.chat.IChatPanel;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatInfo;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatManager;
import com.tencent.qcloud.uikit.business.chat.group.presenter.GroupChatPresenter;
import com.tencent.qcloud.uikit.business.chat.model.MessageInfo;
import com.tencent.qcloud.uikit.business.chat.view.ChatPanel;
import com.tencent.qcloud.uikit.business.chat.view.widget.ChatAdapter;
import com.tencent.qcloud.uikit.common.UIKitConstants;
import com.tencent.qcloud.uikit.common.component.action.PopActionClickListener;
import com.tencent.qcloud.uikit.common.component.action.PopMenuAction;
import com.tencent.qcloud.uikit.common.component.audio.UIKitAudioArmMachine;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;
import com.tencent.qcloud.uikit.operation.group.GroupApplyManagerActivity;
import com.tencent.qcloud.uikit.operation.group.GroupManagerActivity;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by valxehuang on 2018/7/18.
 */

public class GroupChatPanel extends ChatPanel implements IChatPanel {

    GroupChatPresenter mPresenter;
    private GroupChatInfo mBaseInfo;


    public GroupChatPanel(Context context) {
        super(context);
        init();
    }

    public GroupChatPanel(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public GroupChatPanel(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        mTipsGroup.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                getContext().startActivity(new Intent(getContext(), GroupApplyManagerActivity.class));
                postDelayed(new Runnable() {
                    @Override
                    public void run() {

                        mTipsGroup.setVisibility(View.GONE);
                    }
                }, 500);
            }
        });
    }


    public void setBaseChatId(String peer) {
        mPresenter = new GroupChatPresenter(this);
        mPresenter.getGroupChatInfo(peer);


    }


    public void onGroupInfoLoaded(GroupChatInfo groupInfo) {
        if (groupInfo == null)
            return;
        mBaseInfo = groupInfo;
        mPresenter.loadChatMessages(null);
        mPresenter.loadApplyInfos();
        String chatTitle = mBaseInfo.getChatName();
       /* if (mBaseInfo.getMemberCount() > 0)
            chatTitle = chatTitle + "(" + mBaseInfo.getMemberCount() + "人)";*/
        mTitleBar.setTitle(chatTitle, PageTitleBar.POSITION.CENTER);
        mTitleBar.getLeftGroup().setVisibility(View.VISIBLE);
    }


    public void onChatActive(Object object) {
        mTipsContent.setText(object + getResources().getString(R.string.group_apply_tips));
        mTipsGroup.setVisibility(View.VISIBLE);
    }

    public void onGroupNameChanged(String newName) {
        getTitleBar().setTitle(newName, PageTitleBar.POSITION.CENTER);
    }


    @Override
    public void exitChat() {
        mPresenter.exitChat();
        UIKitAudioArmMachine.getInstance().stopRecord();
        GroupChatManager.getInstance().destroyGroupChat();
    }


    @Override
    public void sendMessage(MessageInfo messageInfo) {
        mPresenter.sendGroupMessage(messageInfo);
    }

    @Override
    public void loadMessages() {
        mPresenter.loadChatMessages(mAdapter.getItemCount() > 0 ? mAdapter.getItem(1) : null);
    }

    @Override
    public void initDefault() {
        super.initDefault();
        ChatAdapter adapter = new ChatAdapter();
        setChatAdapter(adapter);
        initDefaultEvent();
        mTitleBar.getRightIcon().setImageResource(R.drawable.group_icon);
        mTitleBar.setRightClick(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(getContext(), GroupManagerActivity.class);
                intent.putExtra(UIKitConstants.GROUP_ID, mBaseInfo.getPeer());
                getContext().startActivity(intent);

            }
        });
    }

    @Override
    protected void initPopActions(final MessageInfo msg) {
        List<PopMenuAction> actions = new ArrayList<>();
        PopMenuAction action = new PopMenuAction();
        action.setActionName("删除");
        action.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int position, Object data) {
                mPresenter.deleteMessage(position, (MessageInfo) data);
            }
        });
        actions.add(action);
        if (msg.isSelf()) {

            action = new PopMenuAction();
            action.setActionName("撤销");
            action.setActionClickListener(new PopActionClickListener() {
                @Override
                public void onActionClick(int position, Object data) {
                    mPresenter.revokeMessage(position, (MessageInfo) data);
                }
            });
            actions.add(action);
            if (msg.getStatus() == MessageInfo.MSG_STATUS_SEND_FAIL) {
                action = new PopMenuAction();
                action.setActionName("重发");
                action.setActionClickListener(new PopActionClickListener() {
                    @Override
                    public void onActionClick(int position, Object data) {
                        sendMessage(msg);
                    }
                });
                actions.add(action);
            }
        }
        setMessagePopActions(actions, false);
    }

    public void forceStopChat() {
        if (getContext() instanceof Activity) {
            ((Activity) getContext()).finish();
        }

    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        exitChat();
    }
}
