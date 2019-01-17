package com.tencent.qcloud.uikit.business.chat.group.view;

import android.app.Activity;
import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.ListView;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.chat.group.view.widget.GroupApplyAdapter;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;

/**
 * Created by valxehuang on 2018/7/30.
 */

public class GroupApplyManagerPanel extends LinearLayout {
    private PageTitleBar mTitleBar;
    private ListView mApplyMemberList;
    private GroupApplyAdapter mAdapter;

    public GroupApplyManagerPanel(Context context) {
        super(context);
        init();
    }

    public GroupApplyManagerPanel(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public GroupApplyManagerPanel(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.group_apply_manager_panel, this);
        mApplyMemberList = findViewById(R.id.group_apply_members);
        mAdapter = new GroupApplyAdapter();
        mApplyMemberList.setAdapter(mAdapter);
        mTitleBar = findViewById(R.id.group_apply_title_bar);
        mTitleBar.getRightGroup().setVisibility(View.GONE);
        mTitleBar.setTitle(getResources().getString(R.string.group_apply_members), PageTitleBar.POSITION.CENTER);
        mTitleBar.setLeftClick(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (getContext() instanceof Activity) {
                    ((Activity) getContext()).finish();
                }
            }
        });
    }

    public PageTitleBar getTitleBar() {
        return mTitleBar;
    }

}
