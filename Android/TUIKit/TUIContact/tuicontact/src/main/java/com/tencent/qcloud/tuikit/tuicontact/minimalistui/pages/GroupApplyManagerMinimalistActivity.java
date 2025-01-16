package com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages;

import android.os.Bundle;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseMinimalistLightActivity;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.widget.GroupApplyManagerLayout;
import com.tencent.qcloud.tuikit.tuicontact.presenter.GroupApplyPresenter;

public class GroupApplyManagerMinimalistActivity extends BaseMinimalistLightActivity {
    private GroupApplyManagerLayout mManagerLayout;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.group_minimalist_apply_manager_activity);
        if (getIntent().getExtras() == null) {
            finish();
            return;
        }
        mManagerLayout = findViewById(R.id.group_apply_manager_layout);

        GroupApplyPresenter presenter = new GroupApplyPresenter(mManagerLayout);
        mManagerLayout.setPresenter(presenter);

        String groupId = getIntent().getExtras().getString(TUIContactConstants.Group.GROUP_ID);
        GroupInfo groupInfo = new GroupInfo();
        groupInfo.setId(groupId);
        mManagerLayout.setDataSource(groupInfo);
    }
}
