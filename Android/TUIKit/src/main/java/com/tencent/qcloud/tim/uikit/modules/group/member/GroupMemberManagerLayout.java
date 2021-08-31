package com.tencent.qcloud.tim.uikit.modules.group.member;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import android.util.AttributeSet;
import android.view.View;
import android.widget.AbsListView;
import android.widget.Button;
import android.widget.GridView;
import android.widget.LinearLayout;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.component.TitleBarLayout;
import com.tencent.qcloud.tim.uikit.modules.group.info.GroupInfo;
import com.tencent.qcloud.tim.uikit.modules.group.info.GroupInfoFragment;
import com.tencent.qcloud.tim.uikit.modules.group.info.GroupInfoLayout;
import com.tencent.qcloud.tim.uikit.modules.group.interfaces.IGroupMemberLayout;
import com.tencent.qcloud.tim.uikit.utils.PopWindowUtil;


public class GroupMemberManagerLayout extends LinearLayout implements IGroupMemberLayout {

    private TitleBarLayout mTitleBar;
    private AlertDialog mDialog;
    private GroupMemberManagerAdapter mAdapter;
    private IGroupMemberRouter mGroupMemberManager;
    private GroupInfo mGroupInfo;
    private GroupInfoFragment.GroupMembersListener mGroupMembersListener;

    public GroupMemberManagerLayout(Context context) {
        super(context);
        init();
    }

    public GroupMemberManagerLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public GroupMemberManagerLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.group_member_layout, this);
        mTitleBar = findViewById(R.id.group_member_title_bar);
        mTitleBar.setTitle(getContext().getString(R.string.manager), TitleBarLayout.POSITION.RIGHT);
        mTitleBar.getRightIcon().setVisibility(GONE);
        mTitleBar.setOnRightClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                buildPopMenu();
            }
        });
        mAdapter = new GroupMemberManagerAdapter();
        mAdapter.setMemberChangedCallback(new IGroupMemberChangedCallback() {

            @Override
            public void onMemberRemoved(GroupMemberInfo memberInfo) {
                mTitleBar.setTitle(getContext().getString(R.string.group_members) + "(" + mGroupInfo.getMemberDetails().size() + ")", TitleBarLayout.POSITION.MIDDLE);
            }
        });
        GridView gridView = findViewById(R.id.group_all_members);
        gridView.setAdapter(mAdapter);

        // 监听listview滚到最底部
        gridView.setOnScrollListener(new AbsListView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(AbsListView view, int scrollState) {
                switch (scrollState) {
                    // 当不滚动时
                    case AbsListView.OnScrollListener.SCROLL_STATE_IDLE:
                        // 判断滚动到底部
                        if (view.getLastVisiblePosition() == (view.getCount() - 1)) {
                            if (mGroupMembersListener != null && mGroupInfo.getNextSeq() != 0) {
                                mGroupMembersListener.loadMoreGroupMember(mGroupInfo.getNextSeq());
                                mAdapter.notifyDataSetChanged();
                            }
                        }
                        break;
                }
            }

            @Override
            public void onScroll(AbsListView view, int firstVisibleItem,
                                 int visibleItemCount, int totalItemCount) {
            }
        });
    }

    public void setGroupMembersListener(GroupInfoFragment.GroupMembersListener listener) {
        mGroupMembersListener = listener;
    }

    public TitleBarLayout getTitleBar() {
        return mTitleBar;
    }

    @Override
    public void setParentLayout(Object parent) {

    }

    public void setDataSource(GroupInfo groupInfo) {
        mGroupInfo = groupInfo;
        mAdapter.setDataSource(groupInfo);
        if (groupInfo != null) {
            mTitleBar.setTitle(getContext().getString(R.string.group_members) + "(" + groupInfo.getMemberDetails().size() + ")", TitleBarLayout.POSITION.MIDDLE);
        }
    }

    private void buildPopMenu() {
        if (mGroupInfo == null) {
            return;
        }
        if (mDialog == null) {
            mDialog = PopWindowUtil.buildFullScreenDialog((Activity) getContext());
            View moreActionView = inflate(getContext(), R.layout.group_member_pop_menu, null);
            moreActionView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    mDialog.dismiss();
                }
            });
            Button addBtn = moreActionView.findViewById(R.id.add_group_member);
            addBtn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (mGroupMemberManager != null) {
                        mGroupMemberManager.forwardAddMember(mGroupInfo);
                    }
                    mDialog.dismiss();

                }
            });
            Button deleteBtn = moreActionView.findViewById(R.id.remove_group_member);
            if (!mGroupInfo.isOwner()) {
                deleteBtn.setVisibility(View.GONE);
            }
            deleteBtn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (mGroupMemberManager != null) {
                        mGroupMemberManager.forwardDeleteMember(mGroupInfo);
                    }
                    mDialog.dismiss();
                }
            });
            Button cancelBtn = moreActionView.findViewById(R.id.cancel);
            cancelBtn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    mDialog.dismiss();
                }
            });
            mDialog.setContentView(moreActionView);
        } else {
            mDialog.show();
        }

    }

    public void setRouter(IGroupMemberRouter callBack) {
        this.mGroupMemberManager = callBack;
    }

}
