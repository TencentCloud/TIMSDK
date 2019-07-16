package com.tencent.qcloud.tim.demo.chat;

import android.app.Activity;
import android.os.Bundle;
import android.support.annotation.Nullable;

import com.tencent.qcloud.tim.demo.R;

public class ChatActivity extends Activity {

    private ChatFragment mChatFragment;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.chat_activity);

        Bundle bundle = getIntent().getExtras();
        mChatFragment = new ChatFragment();
        mChatFragment.setArguments(bundle);
        getFragmentManager().beginTransaction().replace(R.id.empty_view, mChatFragment).commitAllowingStateLoss();
    }
}
