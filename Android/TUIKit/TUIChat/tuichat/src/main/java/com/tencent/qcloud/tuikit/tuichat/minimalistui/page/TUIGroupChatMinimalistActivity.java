package com.tencent.qcloud.tuikit.tuichat.minimalistui.page;

import android.os.Bundle;

import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuichat.presenter.GroupChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

public class TUIGroupChatMinimalistActivity extends TUIBaseChatMinimalistActivity {
    private static final String TAG = TUIGroupChatMinimalistActivity.class.getSimpleName();

    private TUIGroupChatMinimalistFragment chatFragment;
    private GroupChatPresenter presenter;

    @Override
    public void initChat(ChatInfo chatInfo) {
        TUIChatLog.i(TAG, "inti chat " + chatInfo);

        if (!TUIChatUtils.isGroupChat(chatInfo.getType())) {
            TUIChatLog.e(TAG, "init group chat failed , chatInfo = " + chatInfo);
            ToastUtil.toastShortMessage("init group chat failed.");
        }
        GroupInfo groupInfo = (GroupInfo) chatInfo;

        chatFragment = new TUIGroupChatMinimalistFragment();
        Bundle bundle = new Bundle();
        bundle.putSerializable(TUIChatConstants.CHAT_INFO, groupInfo);
        chatFragment.setArguments(bundle);
        presenter = new GroupChatPresenter();
        presenter.initListener();
        chatFragment.setPresenter(presenter);
        getSupportFragmentManager().beginTransaction().replace(R.id.empty_view, chatFragment).commitAllowingStateLoss();
    }
}