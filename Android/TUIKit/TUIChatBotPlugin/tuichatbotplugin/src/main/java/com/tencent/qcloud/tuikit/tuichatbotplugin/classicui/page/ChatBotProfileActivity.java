package com.tencent.qcloud.tuikit.tuichatbotplugin.classicui.page;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.tuichatbotplugin.R;
import com.tencent.qcloud.tuikit.tuichatbotplugin.classicui.widget.ChatBotProfileLayout;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.presenter.FriendProfilePresenter;

public class ChatBotProfileActivity extends BaseLightActivity {
    private FriendProfilePresenter presenter;
    private ChatBotProfileLayout layout;
    private String mChatId;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.chat_bot_profile_activity);
        layout = findViewById(R.id.friend_profile);

        presenter = new FriendProfilePresenter();
        layout.setPresenter(presenter);
        presenter.setFriendProfileLayout(layout);
        Intent intent = getIntent();
        mChatId = intent.getStringExtra(TUIConstants.TUIChat.CHAT_ID);

        if (!TextUtils.isEmpty(mChatId)) {
            layout.initData(mChatId);
        } else {
            layout.initData(intent.getSerializableExtra(TUIContactConstants.ProfileType.CONTENT));
        }
    }
}
