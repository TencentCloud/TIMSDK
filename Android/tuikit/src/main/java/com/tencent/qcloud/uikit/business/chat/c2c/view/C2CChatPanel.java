package com.tencent.qcloud.uikit.business.chat.c2c.view;

import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.api.chat.IChatPanel;
import com.tencent.qcloud.uikit.business.chat.c2c.model.C2CChatInfo;
import com.tencent.qcloud.uikit.business.chat.c2c.model.C2CChatManager;
import com.tencent.qcloud.uikit.business.chat.c2c.presenter.C2CChatPresenter;
import com.tencent.qcloud.uikit.common.component.action.PopActionClickListener;
import com.tencent.qcloud.uikit.common.component.action.PopMenuAction;
import com.tencent.qcloud.uikit.business.chat.model.MessageInfo;
import com.tencent.qcloud.uikit.business.chat.view.ChatPanel;
import com.tencent.qcloud.uikit.business.chat.view.widget.ChatAdapter;
import com.tencent.qcloud.uikit.common.component.audio.UIKitAudioArmMachine;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by valxehuang on 2018/7/18.
 */

public class C2CChatPanel extends ChatPanel implements IChatPanel {

    C2CChatPresenter mPresenter;
    private C2CChatInfo mBaseInfo;

    public C2CChatPanel(Context context) {
        super(context);
        init();
    }

    public C2CChatPanel(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public C2CChatPanel(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {

    }


    public void setBaseChatId(String chatId) {
        mPresenter = new C2CChatPresenter(this);
        this.mBaseInfo = mPresenter.getC2CChatInfo(chatId);
        if (mBaseInfo == null)
            return;
        String chatTitle = mBaseInfo.getChatName();
        mTitleBar.setTitle(chatTitle, PageTitleBar.POSITION.CENTER);
        mPresenter.loadChatMessages(null);
    }

    @Override
    public void exitChat() {
        UIKitAudioArmMachine.getInstance().stopRecord();
        C2CChatManager.getInstance().destroyC2CChat();
    }


    @Override
    public void sendMessage(MessageInfo messageInfo) {
        mPresenter.sendC2CMessage(messageInfo, false);
    }

    @Override
    public void loadMessages() {
        mPresenter.loadChatMessages(mAdapter.getItemCount() > 0 ? mAdapter.getItem(1) : null);
    }

    @Override
    public void initDefault() {
        super.initDefault();
        mTitleBar.getLeftGroup().setVisibility(View.VISIBLE);
        mTitleBar.getRightGroup().setVisibility(GONE);
        ChatAdapter adapter = new ChatAdapter();
        setChatAdapter(adapter);
        initDefaultEvent();
    }

    @Override
    protected void initPopActions(final MessageInfo msg) {
        List<PopMenuAction> actions = new ArrayList<>();
        PopMenuAction action = new PopMenuAction();
        action.setActionName("删除");
        action.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int position, Object data) {
                mPresenter.deleteC2CMessage(position, (MessageInfo) data);
            }
        });
        actions.add(action);
        if (msg.isSelf()) {

            action = new PopMenuAction();
            action.setActionName("撤销");
            action.setActionClickListener(new PopActionClickListener() {
                @Override
                public void onActionClick(int position, Object data) {
                    mPresenter.revokeC2CMessage(position, (MessageInfo) data);
                }
            });
            actions.add(action);
            if (msg.getStatus() == MessageInfo.MSG_STATUS_SEND_FAIL) {
                action = new PopMenuAction();
                action.setActionName("重发");
                action.setActionClickListener(new PopActionClickListener() {
                    @Override
                    public void onActionClick(int position, Object data) {
                        mPresenter.sendC2CMessage(msg, true);
                    }
                });
                actions.add(action);
            }
        }
        setMessagePopActions(actions, false);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        exitChat();
    }
}
