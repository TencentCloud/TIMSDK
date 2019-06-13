package com.tencent.qcloud.tim.demo.chat;

import android.app.Activity;
import android.os.Bundle;
import android.support.annotation.Nullable;

import com.tencent.qcloud.tim.demo.R;

public class ChatActivity extends Activity {

    private ChatFragment chatFragment;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.chat_activity);

        Bundle bundle = getIntent().getExtras();
        chatFragment = new ChatFragment();
        chatFragment.setArguments(bundle);
        getFragmentManager().beginTransaction().replace(R.id.empty_view, chatFragment).commitAllowingStateLoss();
    }
}
