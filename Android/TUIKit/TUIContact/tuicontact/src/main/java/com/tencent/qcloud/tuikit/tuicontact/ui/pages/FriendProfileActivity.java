package com.tencent.qcloud.tuikit.tuicontact.ui.pages;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;

import androidx.annotation.Nullable;

import com.tencent.imsdk.v2.V2TIMGroupApplication;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactGroupApplyInfo;
import com.tencent.qcloud.tuikit.tuicontact.presenter.FriendProfilePresenter;
import com.tencent.qcloud.tuikit.tuicontact.util.ContactUtils;
import com.tencent.qcloud.tuikit.tuicontact.ui.view.FriendProfileLayout;

public class FriendProfileActivity extends BaseLightActivity {

    private FriendProfilePresenter presenter;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.contact_friend_profile_activity);
        FriendProfileLayout layout = findViewById(R.id.friend_profile);

        presenter = new FriendProfilePresenter();
        layout.setPresenter(presenter);
        presenter.setFriendProfileLayout(layout);
        Intent intent = getIntent();
        String chatId = intent.getStringExtra(TUIConstants.TUIChat.CHAT_ID);
        String fromUser = intent.getStringExtra("fromUser");
        String fromUserNickName = intent.getStringExtra("fromUserNickName");
        String requestMsg = intent.getStringExtra("requestMsg");
        V2TIMGroupApplication application = (V2TIMGroupApplication) intent.getSerializableExtra("groupApplication");

        if (!TextUtils.isEmpty(chatId)) {
            layout.initData(chatId);
        } else if (!TextUtils.isEmpty(fromUser)) {
            ContactGroupApplyInfo contactGroupApplyInfo = new ContactGroupApplyInfo();
            contactGroupApplyInfo.setFromUser(fromUser);
            contactGroupApplyInfo.setFromUserNickName(fromUserNickName);
            contactGroupApplyInfo.setRequestMsg(requestMsg);
            contactGroupApplyInfo.setTimGroupApplication(application);
            layout.initData(contactGroupApplyInfo);
        } else {
            layout.initData(intent.getSerializableExtra(TUIContactConstants.ProfileType.CONTENT));
        }
        layout.setOnButtonClickListener(new FriendProfileLayout.OnButtonClickListener() {
            @Override
            public void onStartConversationClick(ContactItemBean info) {
                String chatName = info.getId();
                if (!TextUtils.isEmpty(info.getRemark())) {
                    chatName = info.getRemark();
                } else if (!TextUtils.isEmpty(info.getNickName())) {
                    chatName = info.getNickName();
                }
                ContactUtils.startChatActivity(info.getId(), ContactItemBean.TYPE_C2C, chatName, "");
            }

            @Override
            public void onDeleteFriendClick(String id) {
                finish();
            }
        });
    }

}
