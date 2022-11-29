package com.tencent.qcloud.tuikit.tuigroup.minimalistui.page;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupConstants;

import java.util.List;


public class GroupInfoMinimalistActivity extends BaseLightActivity {

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

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_FOR_CHANGE_OWNER && data != null) {
            List<String> selectedList = data.getStringArrayListExtra(TUIGroupConstants.Selection.LIST);
            if (selectedList != null && !selectedList.isEmpty()) {
                String newOwnerId = selectedList.get(0);
                fragment.changeGroupOwner(newOwnerId);
            }
        }
    }
}
