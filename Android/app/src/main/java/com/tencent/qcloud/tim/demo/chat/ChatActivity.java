package com.tencent.qcloud.tim.demo.chat;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;

import com.tencent.qcloud.tim.demo.BaseActivity;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.SplashActivity;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.uikit.modules.chat.base.ChatInfo;

import java.util.Set;

public class ChatActivity extends BaseActivity {

    private static final String TAG = ChatActivity.class.getSimpleName();

    private ChatFragment mChatFragment;
    private ChatInfo mChatInfo;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.chat_activity);

        chat(getIntent());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        DemoLog.i(TAG, "onNewIntent");
        super.onNewIntent(intent);
        chat(intent);
    }

    @Override
    protected void onResume() {
        DemoLog.i(TAG, "onResume");
        super.onResume();
    }

    private void chat(Intent intent) {
        Bundle bundle = intent.getExtras();
        DemoLog.i(TAG, "bundle: " + bundle + " intent: " + intent);
        if (bundle == null) {
            Uri uri = intent.getData();
            if (uri != null) {
                // 离线推送测试代码，oppo scheme url解析
                Set<String> set = uri.getQueryParameterNames();
                if (set != null) {
                    for (String key : set) {
                        String value = uri.getQueryParameter(key);
                        DemoLog.i(TAG, "oppo push scheme url key: " + key + " value: " + value);
                    }
                }
            }
            startSplashActivity();
        } else {

            // 离线推送测试代码，华为和oppo可以通过在控制台设置打开应用内界面为ChatActivity来测试发送的ext数据
            String ext = bundle.getString("ext");
            DemoLog.i(TAG, "huawei push custom data ext: " + ext);

            Set<String> set = bundle.keySet();
            if (set != null) {
                for (String key : set) {
                    String value = bundle.getString(key);
                    DemoLog.i(TAG, "oppo push custom data key: " + key + " value: " + value);
                }
            }
            // 离线推送测试代码结束

            mChatInfo = (ChatInfo) bundle.getSerializable(Constants.CHAT_INFO);
            if (mChatInfo == null) {
                startSplashActivity();
                return;
            }
            mChatFragment = new ChatFragment();
            mChatFragment.setArguments(bundle);
            getFragmentManager().beginTransaction().replace(R.id.empty_view, mChatFragment).commitAllowingStateLoss();
        }
    }

    private void startSplashActivity() {
        Intent intent = new Intent(ChatActivity.this, SplashActivity.class);
        startActivity(intent);
        finish();
    }
}
