package com.tencent.qcloud.tuikit.tuichat.minimalistui.page;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.C2CChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupChatInfo;
import com.tencent.qcloud.tuikit.tuichat.classicui.page.FriendProfileActivity;
import com.tencent.qcloud.tuikit.tuichat.presenter.GroupChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class TUIGroupChatMinimalistFragment extends TUIBaseChatMinimalistFragment {
    private static final String TAG = TUIGroupChatMinimalistFragment.class.getSimpleName();

    private final GroupChatPresenter presenter;

    public TUIGroupChatMinimalistFragment() {
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
        setTitleBarClickAction();
        presenter.getGroupType(chatInfo.getId(), new TUIValueCallback<String>() {
            @Override
            public void onSuccess(String type) {
                ((GroupChatInfo) chatInfo).setGroupType(type);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
            }
        });
    }

    private void setTitleBarClickAction() {
        chatView.setOnAvatarClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getContext(), GroupInfoMinimalistActivity.class);
                intent.putExtra(TUIChatConstants.GROUP_ID, chatInfo.getId());
                intent.putExtra(TUIChatConstants.CHAT_BACKGROUND_URI, mChatBackgroundThumbnailUrl);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }
        });
    }

    @Override
    protected void onUserIconLongClicked(TUIMessageBean messageBean) {
        String resultId = messageBean.getSender();
        String resultName = messageBean.getUserDisplayName();
        chatView.getInputLayout().addInputText(resultName, resultId);
    }

    @Override
    public GroupChatPresenter getPresenter() {
        return presenter;
    }

    @Override
    public ChatInfo getChatInfo() {
        return this.chatInfo;
    }

    public void setChatInfo(GroupChatInfo groupChatInfo) {
        this.chatInfo = groupChatInfo;
    }
}
