package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.page;

import android.os.Bundle;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseMinimalistLightActivity;
import com.tencent.qcloud.tuikit.tuiconversation.R;

public class TUIFoldedConversationMinimalistActivity extends BaseMinimalistLightActivity {
    private TUIFoldedConversationMinimalistFragment mTUIFoldedConversationMinimalistFragment;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.folded_activity);

        init();
    }

    private void init() {
        mTUIFoldedConversationMinimalistFragment = new TUIFoldedConversationMinimalistFragment();
        getSupportFragmentManager().beginTransaction().replace(R.id.empty_view, mTUIFoldedConversationMinimalistFragment).commitAllowingStateLoss();
    }
}
