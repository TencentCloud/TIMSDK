package com.tencent.qcloud.tuikit.tuichat.minimalistui.page;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.Nullable;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuikit.tuichat.presenter.GroupChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

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
                String result_id = messageBean.getV2TIMMessage().getSender();
                String result_name = messageBean.getV2TIMMessage().getNickName();
                chatView.getInputLayout().addInputText(result_name, result_id);
            }

            @Override
            public void onReEditRevokeMessage(View view, int position, TUIMessageBean messageInfo) {
                if (messageInfo == null) {
                    return;
                }
                int messageType = messageInfo.getMsgType();
                if (messageType == V2TIMMessage.V2TIM_ELEM_TYPE_TEXT){
                    chatView.getInputLayout().appendText(messageInfo.getV2TIMMessage().getTextElem().getText());
                } else {
                    TUIChatLog.e(TAG, "error type: " + messageType);
                }
            }

            @Override
            public void onRecallClick(View view, int position, TUIMessageBean messageInfo) {

            }

            @Override
            public void onTextSelected(View view, int position, TUIMessageBean messageInfo) {
                chatView.getMessageLayout().setSelectedPosition(position);
                chatView.getMessageLayout().showItemPopMenu(messageInfo, view);
            }
        });

        chatView.setOnAvatarClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (TUIChatUtils.isTopicGroup(groupInfo.getId())) {
                    Bundle bundle = new Bundle();
                    bundle.putString(TUIConstants.TUICommunity.TOPIC_ID, groupInfo.getId());
                    TUICore.startActivity(getContext(), "TopicInfoActivity", bundle);
                } else {
                    Bundle bundle = new Bundle();
                    bundle.putString(TUIChatConstants.Group.GROUP_ID, groupInfo.getId());
                    bundle.putString(TUIConstants.TUIChat.CHAT_BACKGROUND_URI, mChatBackgroundThumbnailUrl);
                    TUICore.startActivity(getContext(), "GroupInfoMinimalistActivity", bundle);
                }
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
