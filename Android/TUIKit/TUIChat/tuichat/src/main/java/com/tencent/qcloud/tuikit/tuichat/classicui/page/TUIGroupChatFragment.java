package com.tencent.qcloud.tuikit.tuichat.classicui.page;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.Nullable;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.interfaces.ChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.presenter.GroupChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TUIGroupChatFragment extends TUIBaseChatFragment {
    private static final String TAG = TUIGroupChatFragment.class.getSimpleName();

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
            public void onMessageLongClick(View view, TUIMessageBean messageBean) {
                chatView.getMessageLayout().showItemPopMenu(messageBean, view);
            }

            @Override
            public void onMessageClick(View view, TUIMessageBean messageBean) {
                if (messageBean instanceof MergeMessageBean && getChatInfo() != null) {
                    Bundle bundle = new Bundle();
                    bundle.putSerializable(TUIChatConstants.FORWARD_MERGE_MESSAGE_KEY, messageBean);
                    bundle.putSerializable(TUIChatConstants.CHAT_INFO, getChatInfo());
                    TUICore.startActivity("TUIForwardChatActivity", bundle);
                }
            }

            @Override
            public void onUserIconClick(View view, TUIMessageBean messageBean) {
                if (null == messageBean) {
                    return;
                }

                ChatInfo info = new ChatInfo();
                info.setId(messageBean.getSender());

                Bundle bundle = new Bundle();
                bundle.putString(TUIConstants.TUIChat.CHAT_ID, info.getId());
                TUICore.startActivity("FriendProfileActivity", bundle);
            }

            @Override
            public void onUserIconLongClick(View view, TUIMessageBean messageBean) {
                String resultId = messageBean.getV2TIMMessage().getSender();
                String resultName = messageBean.getV2TIMMessage().getNickName();
                chatView.getInputLayout().addInputText(resultName, resultId);
            }

            @Override
            public void onReEditRevokeMessage(View view, TUIMessageBean messageInfo) {
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
            public void onTextSelected(View view, int position, TUIMessageBean messageInfo) {
                chatView.getMessageLayout().setSelectedPosition(position);
                chatView.getMessageLayout().showItemPopMenu(messageInfo, view);
            }

            @Override
            public void onMessageReadStatusClick(View view, TUIMessageBean messageBean) {
                if (messageBean != null && getChatInfo() != null) {
                    Bundle bundle = new Bundle();
                    bundle.putSerializable(TUIChatConstants.MESSAGE_BEAN, messageBean);
                    bundle.putSerializable(TUIChatConstants.CHAT_INFO, getChatInfo());
                    TUICore.startActivity("MessageReceiptDetailActivity", bundle);
                }
            }
        });

        setTitleBarExtension();
    }

    private void setTitleBarExtension() {
        Map<String, Object> param = new HashMap<>();
        if (TUIChatUtils.isTopicGroup(groupInfo.getId())) {
            param.put(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.TOPIC_ID, groupInfo.getId());
        } else {
            param.put(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.GROUP_ID, groupInfo.getId());
        }
        List<TUIExtensionInfo> extensionInfoList = TUICore.getExtensionList(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.CLASSIC_EXTENSION_ID, param);
        if (!extensionInfoList.isEmpty()) {
            TUIExtensionInfo extensionInfo = extensionInfoList.get(0);
            titleBar.setRightIcon((Integer) extensionInfo.getIcon());
            titleBar.setOnRightClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    TUIExtensionEventListener eventListener = extensionInfo.getExtensionListener();
                    if (eventListener != null) {
                        Map<String, Object> map = new HashMap<>();
                        if (TUIChatUtils.isTopicGroup(groupInfo.getId())) {
                            map.put(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.TOPIC_ID, groupInfo.getId());
                        } else {
                            map.put(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.GROUP_ID, groupInfo.getId());
                        }
                        map.put(TUIConstants.TUIChat.CHAT_BACKGROUND_URI, mChatBackgroundThumbnailUrl);
                        eventListener.onClicked(map);
                    }
                }
            });
        }
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
