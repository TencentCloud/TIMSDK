package com.tencent.qcloud.tuikit.tuichat.classicui.page;

import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupChatInfo;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

public class TUIGroupChatActivity extends TUIBaseChatActivity {
    private static final String TAG = TUIGroupChatActivity.class.getSimpleName();

    @Override
    public void initChat(ChatInfo chatInfo) {
        TUIChatLog.i(TAG, "inti chat " + chatInfo);

        if (!(chatInfo instanceof GroupChatInfo)) {
            TUIChatLog.e(TAG, "init group chat failed , chatInfo = " + chatInfo);
            ToastUtil.toastShortMessage("init group chat failed.");
            return;
        }
        GroupChatInfo groupChatInfo = (GroupChatInfo) chatInfo;

        TUIGroupChatFragment chatFragment = new TUIGroupChatFragment();
        chatFragment.setChatInfo(groupChatInfo);

        getSupportFragmentManager().beginTransaction().replace(R.id.empty_view, chatFragment).commitAllowingStateLoss();
    }
}