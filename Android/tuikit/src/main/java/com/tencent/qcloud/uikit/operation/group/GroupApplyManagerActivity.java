package com.tencent.qcloud.uikit.operation.group;

import android.app.Activity;
import android.os.Bundle;
import android.support.annotation.Nullable;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.chat.group.view.GroupApplyManagerPanel;

public class GroupApplyManagerActivity extends Activity {

    private GroupApplyManagerPanel mManagerPanel;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.group_apply_manager_activity);
        mManagerPanel = findViewById(R.id.group_apply_manager_panel);
    }



}
