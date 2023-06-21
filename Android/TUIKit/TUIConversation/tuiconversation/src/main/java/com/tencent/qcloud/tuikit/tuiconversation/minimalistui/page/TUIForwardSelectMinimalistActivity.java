package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.page;

import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.commonutil.TUIConversationLog;

public class TUIForwardSelectMinimalistActivity extends AppCompatActivity {
    private static final String TAG = TUIForwardSelectMinimalistActivity.class.getSimpleName();

    private TUIForwardSelectMinimalistFragment forwardSelectMinimalistFragment;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.forward_activity);

        init();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        TUIConversationLog.i(TAG, "onNewIntent");
        super.onNewIntent(intent);
        ;
    }

    @Override
    protected void onResume() {
        TUIConversationLog.i(TAG, "onResume");
        super.onResume();
    }

    private void init() {
        forwardSelectMinimalistFragment = new TUIForwardSelectMinimalistFragment();
        getSupportFragmentManager().beginTransaction().replace(R.id.empty_view, forwardSelectMinimalistFragment).commitAllowingStateLoss();
    }
}
