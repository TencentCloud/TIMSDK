package com.tencent.qcloud.tim.uikit.modules.group.apply;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.ListView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.component.TitleBarLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.GroupChatManagerKit;
import com.tencent.qcloud.tim.uikit.modules.group.info.GroupInfo;
import com.tencent.qcloud.tim.uikit.modules.group.interfaces.IGroupMemberLayout;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;


public class GroupApplyManagerLayout extends LinearLayout implements IGroupMemberLayout {

    private TitleBarLayout mTitleBar;
    private ListView mApplyMemberList;
    private GroupApplyAdapter mAdapter;

    public GroupApplyManagerLayout(Context context) {
        super(context);
        init();
    }

    public GroupApplyManagerLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public GroupApplyManagerLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.group_apply_manager_layout, this);
        mApplyMemberList = findViewById(R.id.group_apply_members);
        mAdapter = new GroupApplyAdapter();
        mAdapter.setOnItemClickListener(new GroupApplyAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(GroupApplyInfo info) {
                Intent intent = new Intent(getContext(), GroupApplyMemberActivity.class);
                intent.putExtra(TUIKitConstants.ProfileType.CONTENT, info);
                ((Activity) getContext()).startActivityForResult(intent, TUIKitConstants.ActivityRequest.CODE_1);
            }
        });
        mApplyMemberList.setAdapter(mAdapter);
        mTitleBar = findViewById(R.id.group_apply_title_bar);
        mTitleBar.getRightGroup().setVisibility(View.GONE);
        mTitleBar.setTitle(getResources().getString(R.string.group_apply_members), TitleBarLayout.POSITION.MIDDLE);
        mTitleBar.setOnLeftClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                GroupChatManagerKit.getInstance().onApplied(mAdapter.getUnHandledSize());
                if (getContext() instanceof Activity) {
                    ((Activity) getContext()).finish();
                }
            }
        });
    }

    public TitleBarLayout getTitleBar() {
        return mTitleBar;
    }

    @Override
    public void setParentLayout(Object parent) {

    }

    @Override
    public void setDataSource(GroupInfo dataSource) {
        mAdapter.setDataSource(dataSource);
        mAdapter.notifyDataSetChanged();
    }

    public void updateItemData(GroupApplyInfo info) {
        mAdapter.updateItemData(info);
    }
}
