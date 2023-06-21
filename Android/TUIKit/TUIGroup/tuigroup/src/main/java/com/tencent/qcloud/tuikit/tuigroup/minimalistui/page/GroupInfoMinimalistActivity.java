package com.tencent.qcloud.tuikit.tuigroup.minimalistui.page;

import android.os.Bundle;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseMinimalistLightActivity;
import com.tencent.qcloud.tuikit.tuigroup.R;

public class GroupInfoMinimalistActivity extends BaseMinimalistLightActivity {
    public static final int REQUEST_FOR_CHANGE_OWNER = 1;

    private GroupInfoMinimalistFragment fragment;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.group_info_activity);
        fragment = new GroupInfoMinimalistFragment();
        fragment.setArguments(getIntent().getExtras());
        getSupportFragmentManager().beginTransaction().replace(R.id.group_manager_base, fragment).commitAllowingStateLoss();
    }

    @Override
    public void finish() {
        super.finish();
        setResult(1001);
    }
}
