package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.page;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.presenter.FriendProfilePresenter;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget.CustomerServiceProfileLayout;

public class CustomerServiceProfileActivity extends BaseLightActivity {
    private FriendProfilePresenter presenter;
    private CustomerServiceProfileLayout layout;
    private String mChatId;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.customer_service_profile_activity);
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
