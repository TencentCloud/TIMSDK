package com.tencent.qcloud.tuikit.tuigroup.ui.view;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.LinearLayout;

import com.tencent.qcloud.tuicore.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuigroup.component.BottomSelectSheet;
import com.tencent.qcloud.tuikit.tuigroup.ui.interfaces.IGroupMemberLayout;
import com.tencent.qcloud.tuikit.tuigroup.ui.interfaces.IGroupMemberChangedCallback;
import com.tencent.qcloud.tuikit.tuigroup.ui.interfaces.IGroupMemberListener;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupInfoPresenter;

import java.util.ArrayList;
import java.util.List;


public class GroupMemberLayout extends LinearLayout implements IGroupMemberLayout {

    private TitleBarLayout mTitleBar;
    private GroupMemberAdapter mAdapter;
    private IGroupMemberListener groupMemberListener;
    private GroupInfo mGroupInfo;
    private RecyclerView recyclerView;
    private boolean isSelectMode;
    private String title;

    private GroupInfoPresenter presenter;

    public GroupMemberLayout(Context context) {
        super(context);
        init();
    }

    public GroupMemberLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public GroupMemberLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.group_member_layout, this);
        mTitleBar = findViewById(R.id.group_member_title_bar);
        mTitleBar.setTitle(getContext().getString(R.string.manager), ITitleBarLayout.Position.RIGHT);
        mTitleBar.getRightIcon().setVisibility(GONE);
        mTitleBar.setOnRightClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                buildPopMenu();
            }
        });
        mAdapter = new GroupMemberAdapter();
        mAdapter.setMemberChangedCallback(new IGroupMemberChangedCallback() {

            @Override
            public void onMemberRemoved(GroupMemberInfo memberInfo) {
                if (!TextUtils.isEmpty(title)) {
                    mTitleBar.setTitle(title, ITitleBarLayout.Position.MIDDLE);
                } else {
                    mTitleBar.setTitle(getContext().getString(R.string.group_members) +
                            "(" + mGroupInfo.getMemberCount() + ")", TitleBarLayout.Position.MIDDLE);
                }
            }
        });
        recyclerView = findViewById(R.id.group_all_members);
        recyclerView.setLayoutManager(new CustomLinearLayoutManager(getContext()));
        recyclerView.setAdapter(mAdapter);
        recyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);
                if (newState == RecyclerView.SCROLL_STATE_IDLE) {
                    // 判断滚动到底部
                    LinearLayoutManager layoutManager = (LinearLayoutManager) recyclerView.getLayoutManager();
                    if (layoutManager == null) {
                        return;
                    }
                    int lastPosition = layoutManager.findLastCompletelyVisibleItemPosition();
                    if (mAdapter != null) {
                        if (lastPosition == mAdapter.getItemCount() - 1) {
                            if (mGroupInfo != null && mGroupInfo.getNextSeq() != 0) {
                                presenter.getGroupMembers(mGroupInfo, new IUIKitCallback<GroupInfo>() {
                                    @Override
                                    public void onSuccess(GroupInfo data) {
                                        onGroupInfoChanged(data);
                                        mAdapter.notifyDataSetChanged();
                                    }

                                    @Override
                                    public void onError(String module, int errCode, String errMsg) {

                                    }
                                });
                            }
                        }
                    }
                }
            }
        });
    }

    public TitleBarLayout getTitleBar() {
        return mTitleBar;
    }

    public void setSelectMode(boolean selectMode) {
        isSelectMode = selectMode;
        if (isSelectMode) {
            mTitleBar.setTitle(getContext().getString(R.string.sure), ITitleBarLayout.Position.RIGHT);
            mTitleBar.getRightGroup().setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (groupMemberListener != null) {
                        groupMemberListener.setSelectedMember(mAdapter.getSelectedMember());
                    }
                }
            });
        }

        mAdapter.setSelectMode(isSelectMode);
    }

    @Override
    public void setParentLayout(Object parent) {

    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void onGroupInfoChanged(GroupInfo groupInfo) {
        mGroupInfo = groupInfo;
        presenter.setGroupInfo(groupInfo);
        mAdapter.setDataSource(groupInfo);
        if (groupInfo != null) {
            if (!TextUtils.isEmpty(title)) {
                mTitleBar.setTitle(title, ITitleBarLayout.Position.MIDDLE);
            } else {
                mTitleBar.setTitle(getContext().getString(R.string.group_members) +
                        "(" + groupInfo.getMemberCount() + ")", TitleBarLayout.Position.MIDDLE);
            }
        }
    }

    @Override
    public void onGroupInfoModified(Object value, int type) {

    }

    private void buildPopMenu() {
        if (mGroupInfo == null) {
            return;
        }

        BottomSelectSheet sheet = new BottomSelectSheet(getContext());
        List<String> stringList = new ArrayList<>();
        String addMember = getResources().getString(R.string.add_group_member);
        String removeMember = getResources().getString(R.string.remove_group_member);
        stringList.add(addMember);
        if (mGroupInfo.isOwner()) {
            stringList.add(removeMember);
        }
        sheet.setSelectList(stringList);
        sheet.setOnClickListener(new BottomSelectSheet.BottomSelectSheetOnClickListener() {
            @Override
            public void onSheetClick(int index) {
                if (index == 0) {
                    if (groupMemberListener != null) {
                        groupMemberListener.forwardAddMember(mGroupInfo);
                    }
                } else if (index == 1) {
                    if (groupMemberListener != null) {
                        groupMemberListener.forwardDeleteMember(mGroupInfo);
                    }
                }
            }
        });
        sheet.show();
    }

    public void setGroupMemberListener(IGroupMemberListener listener) {
        this.groupMemberListener = listener;
    }

    public void setPresenter(GroupInfoPresenter presenter) {
        this.presenter = presenter;
        mAdapter.setPresenter(presenter);
    }
}
