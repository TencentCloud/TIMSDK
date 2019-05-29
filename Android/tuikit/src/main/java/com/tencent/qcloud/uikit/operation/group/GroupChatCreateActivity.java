package com.tencent.qcloud.uikit.operation.group;

import android.app.Activity;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.View;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.chat.group.view.GroupCreatePanel;

public class GroupChatCreateActivity extends Activity {

    GroupCreatePanel createPanel;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.group_create_activity);
        createPanel = findViewById(R.id.group_create_panel);
        createPanel.getTitleBar().setLeftClick(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

    }


}
