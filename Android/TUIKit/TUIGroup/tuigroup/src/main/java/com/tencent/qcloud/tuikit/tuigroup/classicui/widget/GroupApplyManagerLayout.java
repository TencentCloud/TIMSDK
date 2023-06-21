package com.tencent.qcloud.tuikit.tuigroup.classicui.widget;

import static android.app.Activity.RESULT_OK;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.util.AttributeSet;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.ListView;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultCaller;
import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupConstants;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupApplyInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.classicui.page.GroupApplyDetailActivity;
import com.tencent.qcloud.tuikit.tuigroup.interfaces.IGroupApplyLayout;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupApplyPresenter;

import java.util.List;

public class GroupApplyManagerLayout extends LinearLayout implements IGroupApplyLayout {
    private TitleBarLayout mTitleBar;
    private ListView mApplyMemberList;
    private GroupApplyAdapter mAdapter;

    private GroupApplyPresenter presenter;
    
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
                Bundle bundle = new Bundle();
                bundle.putSerializable(TUIGroupConstants.Group.MEMBER_APPLY, info);
                TUICore.startActivityForResult(
                    (ActivityResultCaller) getContext(), GroupApplyDetailActivity.class, bundle, new ActivityResultCallback<ActivityResult>() {
                        @Override
                        public void onActivityResult(ActivityResult result) {
                            if (result.getResultCode() != RESULT_OK || result.getData() == null) {
                                return;
                            }
                            GroupApplyInfo info = (GroupApplyInfo) result.getData().getSerializableExtra(TUIGroupConstants.Group.MEMBER_APPLY);
                            if (info == null) {
                                return;
                            }
                            updateItemData(info);
                        }
                    });
            }
        });
        mApplyMemberList.setAdapter(mAdapter);
        mTitleBar = findViewById(R.id.group_apply_title_bar);
        mTitleBar.getRightGroup().setVisibility(View.GONE);
        mTitleBar.setTitle(getResources().getString(R.string.group_apply_members), ITitleBarLayout.Position.MIDDLE);
        mTitleBar.setOnLeftClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (getContext() instanceof Activity) {
                    ((Activity) getContext()).finish();
                }
            }
        });
    }

    public TitleBarLayout getTitleBar() {
        return mTitleBar;
    }

    public void updateItemData(GroupApplyInfo info) {
        mAdapter.updateItemData(info);
    }

    public void onDataSetChanged() {
        mAdapter.notifyDataSetChanged();
    }

    public void setPresenter(GroupApplyPresenter groupApplyPresenter) {
        this.presenter = groupApplyPresenter;
        mAdapter.setPresenter(groupApplyPresenter);
    }

    public void onGroupApplyInfoListChanged(List<GroupApplyInfo> applyInfoList) {
        mAdapter.setDataSource(applyInfoList);
    }

    public void setDataSource(GroupInfo dataSource) {
        presenter.setGroupInfo(dataSource);
        mAdapter.setDataSource(dataSource);
    }
}
