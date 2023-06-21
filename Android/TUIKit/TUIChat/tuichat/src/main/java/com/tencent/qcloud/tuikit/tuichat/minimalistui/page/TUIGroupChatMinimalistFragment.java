package com.tencent.qcloud.tuikit.tuichat.minimalistui.page;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.Nullable;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.presenter.GroupChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class TUIGroupChatMinimalistFragment extends TUIBaseChatMinimalistFragment {
    private static final String TAG = TUIGroupChatMinimalistFragment.class.getSimpleName();

    private GroupChatPresenter presenter;
    private GroupInfo groupInfo;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        TUIChatLog.i(TAG, "oncreate view " + this);

        baseView = super.onCreateView(inflater, container, savedInstanceState);
        Bundle bundle = getArguments();
        if (bundle == null) {
            return baseView;
        }
        groupInfo = (GroupInfo) bundle.getSerializable(TUIChatConstants.CHAT_INFO);
        if (groupInfo == null) {
            return baseView;
        }

        initView();
        return baseView;
    }

    @Override
    protected void initView() {
        super.initView();
        chatView.setPresenter(presenter);
        presenter.setGroupInfo(groupInfo);
        chatView.setChatInfo(groupInfo);
        chatView.getMessageLayout().setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onMessageLongClick(View view, int position, TUIMessageBean messageBean) {
                chatView.getMessageLayout().showItemPopMenu(messageBean, view);
            }

            @Override
            public void onUserIconClick(View view, int position, TUIMessageBean messageBean) {
                if (null == messageBean) {
                    return;
                }

                ChatInfo info = new ChatInfo();
                info.setId(messageBean.getSender());

                Bundle bundle = new Bundle();
                bundle.putString(TUIConstants.TUIChat.CHAT_ID, info.getId());
                TUICore.startActivity("FriendProfileMinimalistActivity", bundle);
            }

            @Override
            public void onUserIconLongClick(View view, int position, TUIMessageBean messageBean) {
                String resultId = messageBean.getV2TIMMessage().getSender();
                String resultName = messageBean.getV2TIMMessage().getNickName();
                chatView.getInputLayout().addInputText(resultName, resultId);
            }

            @Override
            public void onReEditRevokeMessage(View view, int position, TUIMessageBean messageInfo) {
                if (messageInfo == null) {
                    return;
                }
                int messageType = messageInfo.getMsgType();
                if (messageType == V2TIMMessage.V2TIM_ELEM_TYPE_TEXT) {
                    chatView.getInputLayout().appendText(messageInfo.getV2TIMMessage().getTextElem().getText());
                } else {
                    TUIChatLog.e(TAG, "error type: " + messageType);
                }
            }

            @Override
            public void onRecallClick(View view, int position, TUIMessageBean messageInfo) {}

            @Override
            public void onTextSelected(View view, int position, TUIMessageBean messageInfo) {
                chatView.getMessageLayout().setSelectedPosition(position);
                chatView.getMessageLayout().showItemPopMenu(messageInfo, view);
            }

            @Override
            public void onMessageClick(View view, int position, TUIMessageBean messageBean) {
                if (messageBean instanceof MergeMessageBean) {
                    if (getChatInfo() == null) {
                        return;
                    }
                    Intent intent = new Intent(view.getContext(), TUIForwardChatMinimalistActivity.class);
                    intent.putExtra(TUIChatConstants.FORWARD_MERGE_MESSAGE_KEY, messageBean);
                    intent.putExtra(TUIChatConstants.CHAT_INFO, getChatInfo());
                    startActivity(intent);
                }
            }

            @Override
            public void onMessageReadStatusClick(View view, TUIMessageBean messageBean) {
                if (getChatInfo() != null) {
                    Intent intent = new Intent(getContext(), MessageDetailMinimalistActivity.class);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    intent.putExtra(TUIChatConstants.MESSAGE_BEAN, messageBean);
                    intent.putExtra(TUIChatConstants.CHAT_INFO, getChatInfo());
                    startActivity(intent);
                }
            }
        });
        setTitleBarClickAction();
    }

    private void setTitleBarClickAction() {
        chatView.setOnAvatarClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Bundle param = new Bundle();
                param.putString(TUIChatConstants.GROUP_ID, groupInfo.getId());
                param.putString(TUIConstants.TUIChat.CHAT_BACKGROUND_URI, mChatBackgroundThumbnailUrl);
                TUICore.startActivity("GroupInfoMinimalistActivity", param);
            }
        });
    }

    public void setPresenter(GroupChatPresenter presenter) {
        this.presenter = presenter;
    }

    @Override
    public GroupChatPresenter getPresenter() {
        return presenter;
    }

    @Override
    public ChatInfo getChatInfo() {
        return groupInfo;
    }
}
