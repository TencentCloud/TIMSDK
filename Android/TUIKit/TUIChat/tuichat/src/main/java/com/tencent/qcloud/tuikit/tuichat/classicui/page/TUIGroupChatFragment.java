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
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnItemClickListener;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.C2CChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuichat.presenter.GroupChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TUIGroupChatFragment extends TUIBaseChatFragment {
    private static final String TAG = TUIGroupChatFragment.class.getSimpleName();

    private final GroupChatPresenter presenter;

    public TUIGroupChatFragment() {
        presenter = new GroupChatPresenter();
        presenter.initListener();
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        TUIChatLog.i(TAG, "oncreate view " + this);

        baseView = super.onCreateView(inflater, container, savedInstanceState);
        if (!(chatInfo instanceof GroupChatInfo)) {
            return baseView;
        }
        initView();
        return baseView;
    }

    @Override
    protected void initView() {
        super.initView();
        chatView.setPresenter(presenter);
        presenter.setGroupInfo((GroupChatInfo) chatInfo);
        chatView.setChatInfo(chatInfo);

        presenter.getGroupType(chatInfo.getId(), new TUIValueCallback<String>() {
            @Override
            public void onSuccess(String type) {
                ((GroupChatInfo) chatInfo).setGroupType(type);
                setTitleBarExtension();
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                setTitleBarExtension();
            }
        });
    }

    private void setTitleBarExtension() {
        Map<String, Object> param = new HashMap<>();
        if (TUIChatUtils.isTopicGroup(chatInfo.getId())) {
            param.put(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.TOPIC_ID, chatInfo.getId());
        } else {
            param.put(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.GROUP_ID, chatInfo.getId());
        }
        param.put(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.GROUP_TYPE, ((GroupChatInfo) chatInfo).getGroupType());
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
                        if (TUIChatUtils.isTopicGroup(chatInfo.getId())) {
                            map.put(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.TOPIC_ID, chatInfo.getId());
                        } else {
                            map.put(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.GROUP_ID, chatInfo.getId());
                        }
                        map.put(TUIConstants.TUIChat.CHAT_BACKGROUND_URI, mChatBackgroundThumbnailUrl);
                        eventListener.onClicked(map);
                    }
                }
            });
        }
    }

    @Override
    protected void onUserIconClicked(TUIMessageBean message) {
        if (null == message) {
            return;
        }

        Bundle bundle = new Bundle();
        bundle.putString(TUIConstants.TUIChat.CHAT_ID, message.getSender());
        TUICore.startActivity("FriendProfileActivity", bundle);
    }

    @Override
    protected void onUserIconLongClicked(TUIMessageBean messageBean) {
        String resultId = messageBean.getV2TIMMessage().getSender();
        String resultName = messageBean.getV2TIMMessage().getNickName();
        chatView.getInputLayout().addInputText(resultName, resultId);
    }

    @Override
    public GroupChatPresenter getPresenter() {
        return presenter;
    }

    public GroupChatInfo getChatInfo() {
        return ((GroupChatInfo) chatInfo);
    }

    public void setChatInfo(GroupChatInfo groupChatInfo) {
        this.chatInfo = groupChatInfo;
    }
}
