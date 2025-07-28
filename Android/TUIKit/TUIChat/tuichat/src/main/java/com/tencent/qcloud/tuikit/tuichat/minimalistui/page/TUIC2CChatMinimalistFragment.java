package com.tencent.qcloud.tuikit.tuichat.minimalistui.page;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.timcommon.util.TIMCommonUtil;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.C2CChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.classicui.page.FriendProfileActivity;
import com.tencent.qcloud.tuikit.tuichat.presenter.C2CChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

public class TUIC2CChatMinimalistFragment extends TUIBaseChatMinimalistFragment {
    private static final String TAG = TUIC2CChatMinimalistFragment.class.getSimpleName();

    private final C2CChatPresenter presenter;

    public TUIC2CChatMinimalistFragment() {
        presenter = new C2CChatPresenter();
        presenter.initListener();
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        TUIChatLog.i(TAG, "oncreate view " + this);

        baseView = super.onCreateView(inflater, container, savedInstanceState);
        if (!(chatInfo instanceof C2CChatInfo)) {
            return baseView;
        }

        initView();

        return baseView;
    }

    @Override
    protected void initView() {
        super.initView();

        setTitleBarClickAction();
        chatView.setPresenter(presenter);
        presenter.setTypingListener(chatView.typingListener);
        presenter.setChatInfo((C2CChatInfo) chatInfo);
        chatView.setChatInfo(chatInfo);
    }

    private void setTitleBarClickAction() {
        chatView.setOnAvatarClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (TIMCommonUtil.isChatbot(chatInfo.getId())) {
                    return;
                }
                Intent intent = new Intent(getContext(), FriendProfileMinimalistActivity.class);
                intent.putExtra(TUIConstants.TUIChat.CHAT_ID, chatInfo.getId());
                intent.putExtra(TUIChatConstants.CHAT_BACKGROUND_URI, mChatBackgroundThumbnailUrl);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }
        });
    }

    @Override
    public C2CChatPresenter getPresenter() {
        return presenter;
    }

    @Override
    public ChatInfo getChatInfo() {
        return chatInfo;
    }

    public void setChatInfo(C2CChatInfo chatInfo) {
        this.chatInfo = chatInfo;
    }
}
