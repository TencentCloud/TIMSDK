package com.tencent.qcloud.tuikit.tuigroup.classicui.page;

import android.os.Bundle;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupConstants;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.classicui.widget.GroupApplyManagerLayout;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupApplyPresenter;

public class GroupApplyManagerActivity extends BaseLightActivity {
    private GroupApplyManagerLayout mManagerLayout;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.group_apply_manager_activity);
        if (getIntent().getExtras() == null) {
            finish();
            return;
        }
        mManagerLayout = findViewById(R.id.group_apply_manager_layout);

        GroupApplyPresenter presenter = new GroupApplyPresenter(mManagerLayout);
        mManagerLayout.setPresenter(presenter);

        String groupId = getIntent().getExtras().getString(TUIGroupConstants.Group.GROUP_ID);
        GroupInfo groupInfo = new GroupInfo();
        groupInfo.setId(groupId);
        mManagerLayout.setDataSource(groupInfo);
    }

    @Override
    public void onResume() {
        super.onResume();
    }
}
