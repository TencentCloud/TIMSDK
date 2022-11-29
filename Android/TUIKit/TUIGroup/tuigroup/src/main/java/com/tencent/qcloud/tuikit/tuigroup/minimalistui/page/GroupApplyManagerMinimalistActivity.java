package com.tencent.qcloud.tuikit.tuigroup.minimalistui.page;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupConstants;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupApplyInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.minimalistui.view.GroupApplyManagerLayout;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupApplyPresenter;

public class GroupApplyManagerMinimalistActivity extends BaseLightActivity {

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

        String groupId = getIntent().getExtras().getString(TUIGroupConstants.Group.GROUP_ID);
        GroupInfo groupInfo = new GroupInfo();
        groupInfo.setId(groupId);
        mManagerLayout.setDataSource(groupInfo);
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode != TUIGroupConstants.ActivityRequest.CODE_1) {
            return;
        }
        if (resultCode != RESULT_OK) {
            return;
        }
        GroupApplyInfo info = (GroupApplyInfo) data.getSerializableExtra(TUIGroupConstants.Group.MEMBER_APPLY);
        if (info == null) {
            return;
        }
        mManagerLayout.updateItemData(info);
    }

}
