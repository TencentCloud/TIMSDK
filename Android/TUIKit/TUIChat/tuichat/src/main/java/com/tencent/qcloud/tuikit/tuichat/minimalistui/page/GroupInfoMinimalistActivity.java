package com.tencent.qcloud.tuikit.tuichat.minimalistui.page;

import android.os.Bundle;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseMinimalistLightActivity;
import com.tencent.qcloud.tuikit.tuichat.R;

public class GroupInfoMinimalistActivity extends BaseMinimalistLightActivity {

    private GroupInfoMinimalistFragment fragment;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.group_info_activity);
        fragment = new GroupInfoMinimalistFragment();
        fragment.setArguments(getIntent().getExtras());
        getSupportFragmentManager().beginTransaction().replace(R.id.group_manager_base, fragment).commitAllowingStateLoss();
    }

}
