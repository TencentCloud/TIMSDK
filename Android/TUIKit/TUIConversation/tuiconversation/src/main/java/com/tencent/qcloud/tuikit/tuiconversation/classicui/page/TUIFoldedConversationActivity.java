package com.tencent.qcloud.tuikit.tuiconversation.classicui.page;

import android.os.Bundle;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.tuiconversation.R;

public class TUIFoldedConversationActivity extends BaseLightActivity {
    private TUIFoldedConversationFragment mTUIFoldedConversationFragment;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.folded_activity);

        init();
    }

    private void init() {
        mTUIFoldedConversationFragment = new TUIFoldedConversationFragment();
        getSupportFragmentManager().beginTransaction().replace(R.id.empty_view, mTUIFoldedConversationFragment).commitAllowingStateLoss();
    }
}
