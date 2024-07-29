package com.tencent.qcloud.tuikit.tuichat.classicui.page;

import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.C2CChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.presenter.C2CChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

public class TUIC2CChatActivity extends TUIBaseChatActivity {
    private static final String TAG = TUIC2CChatActivity.class.getSimpleName();

    private TUIC2CChatFragment chatFragment;

    @Override
    public void initChat(ChatInfo chatInfo) {
        TUIChatLog.i(TAG, "inti chat " + chatInfo);

        if (!(chatInfo instanceof C2CChatInfo)) {
            TUIChatLog.e(TAG, "init C2C chat failed , chatInfo = " + chatInfo);
            ToastUtil.toastShortMessage("init c2c chat failed.");
            return;
        }

        chatFragment = new TUIC2CChatFragment();
        chatFragment.setChatInfo((C2CChatInfo) chatInfo);

        getSupportFragmentManager().beginTransaction().replace(R.id.empty_view, chatFragment).commitAllowingStateLoss();
    }

    @Override
    protected void onDestroy() {
        C2CChatPresenter chatPresenter = null;
        if (chatFragment != null) {
            chatPresenter = chatFragment.getPresenter();
        }
        if (chatPresenter != null) {
            chatPresenter.removeC2CChatEventListener();
        }

        super.onDestroy();
    }
}
