package com.tencent.qcloud.tuikit.tuigroup.minimalistui.widget;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.timcommon.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuikit.timcommon.component.RoundCornerImageView;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuigroup.component.BottomSelectSheet;
import com.tencent.qcloud.tuikit.tuigroup.interfaces.IGroupMemberLayout;
import com.tencent.qcloud.tuikit.tuigroup.minimalistui.interfaces.IGroupMemberChangedCallback;
import com.tencent.qcloud.tuikit.tuigroup.minimalistui.interfaces.IGroupMemberListener;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupInfoPresenter;
import java.util.ArrayList;
import java.util.List;

public class GroupMemberLayout extends LinearLayout implements IGroupMemberLayout {
    // 取一个足够大的偏移保证能一次性滚动到最底部
    // Take a large enough offset to scroll to the bottom at one time
    private static final int SCROLL_TO_END_OFFSET = -999999;

    private TitleBarLayout mTitleBar;
    private GroupMemberAdapter mAdapter;
    private IGroupMemberListener groupMemberListener;
    private OnGroupMemberClickListener onGroupMemberClickListener;
    private GroupInfo mGroupInfo;
    private RecyclerView recyclerView;
    private boolean isSelectMode;
    private String title;
    private ArrayList<String> excludeList;
    private ArrayList<String> alreadySelectedList;
    private RecyclerView selectedList;
    private SelectedAdapter selectedListAdapter;
    private View selectArea;
    private TextView confirmButton;

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
        inflate(getContext(), R.layout.group_minimalist_member_layout, this);
        mTitleBar = findViewById(R.id.group_member_title_bar);
        mAdapter = new GroupMemberAdapter();
        mAdapter.setMemberChangedCallback(new IGroupMemberChangedCallback() {
            @Override
            public void onMemberRemoved(GroupMemberInfo memberInfo) {
                if (!TextUtils.isEmpty(title)) {
                    mTitleBar.setTitle(title, ITitleBarLayout.Position.MIDDLE);
                } else {
                    mTitleBar.setTitle(
                        getContext().getString(R.string.group_members) + "(" + mGroupInfo.getMemberCount() + ")", TitleBarLayout.Position.MIDDLE);
                }
            }
        });
        mAdapter.setOnGroupMemberClickListener(new OnGroupMemberClickListener() {
            @Override
            public void onClick(GroupMemberInfo groupMemberInfo) {
                buildPopMenu(groupMemberInfo);
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
                                    public void onError(String module, int errCode, String errMsg) {}
                                });
                            }
                        }
                    }
                }
            }
        });

        selectArea = findViewById(R.id.select_area);
        selectedList = findViewById(R.id.selected_list);
        selectedListAdapter = new SelectedAdapter();
        selectedList.setLayoutManager(new LinearLayoutManager(getContext(), RecyclerView.HORIZONTAL, false));
        selectedList.setAdapter(selectedListAdapter);

        confirmButton = findViewById(R.id.confirm_button);
        confirmButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                confirmAndFinish();
            }
        });

        mAdapter.setOnSelectChangedListener(new OnSelectChangedListener() {
            @Override
            public void onSelectChanged() {
                selectedListAdapter.setMembers(mAdapter.getSelectedMemberInfoList());
                selectedListAdapter.notifyDataSetChanged();
            }
        });
    }

    private void confirmAndFinish() {
        if (groupMemberListener != null) {
            groupMemberListener.setSelectedMember(mAdapter.getSelectedMember());
        }
    }

    public TitleBarLayout getTitleBar() {
        return mTitleBar;
    }

    public void setExcludeList(ArrayList<String> excludeList) {
        this.excludeList = excludeList;
        mAdapter.setExcludeList(excludeList);
    }

    public void setAlreadySelectedList(ArrayList<String> alreadySelectedList) {
        this.alreadySelectedList = alreadySelectedList;
        mAdapter.setAlreadySelectedList(alreadySelectedList);
    }

    public void setSelectMode(boolean selectMode) {
        isSelectMode = selectMode;
        if (isSelectMode) {
            mTitleBar.setTitle(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure), ITitleBarLayout.Position.RIGHT);
            mTitleBar.getRightGroup().setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (groupMemberListener != null) {
                        groupMemberListener.setSelectedMember(mAdapter.getSelectedMember());
                    }
                }
            });
            selectArea.setVisibility(VISIBLE);
        }

        mAdapter.setSelectMode(isSelectMode);
    }

    @Override
    public void setParentLayout(Object parent) {}

    public void setTitle(String title) {
        this.title = title;
    }

    public void deleteMember(List<String> members) {
        mAdapter.deleteMember(members);
    }

    public void memberChanged(GroupMemberInfo groupMemberInfo) {
        mAdapter.memberChanged(groupMemberInfo);
    }

    public void onGroupInfoChanged(GroupInfo groupInfo) {
        mGroupInfo = groupInfo;
        presenter.setGroupInfo(groupInfo);
        mAdapter.setDataSource(groupInfo);
        if (groupInfo != null) {
            if (!TextUtils.isEmpty(title)) {
                mTitleBar.setTitle(title, ITitleBarLayout.Position.MIDDLE);
            } else {
                mTitleBar.setTitle(getContext().getString(R.string.group_members) + "(" + groupInfo.getMemberCount() + ")", TitleBarLayout.Position.MIDDLE);
            }
        }
    }

    @Override
    public void onGroupInfoModified(Object value, int type) {}

    private void buildPopMenu(GroupMemberInfo groupMemberInfo) {
        if (mGroupInfo == null) {
            return;
        }

        List<String> stringList = new ArrayList<>();
        String showInfo = getResources().getString(R.string.group_member_info);
        String setAdminRole = getResources().getString(R.string.group_set_admin);
        String removeMember = getResources().getString(R.string.group_delete);
        stringList.add(showInfo);
        if (presenter.isAdmin(groupMemberInfo.getMemberType())) {
            setAdminRole = getResources().getString(R.string.group_remove_manager_label);
        }
        if (mGroupInfo.isOwner()) {
            stringList.add(setAdminRole);
            stringList.add(removeMember);
        }
        BottomSelectSheet sheet = new BottomSelectSheet(getContext());
        sheet.setSelectList(stringList);
        sheet.setOnClickListener(new BottomSelectSheet.BottomSelectSheetOnClickListener() {
            @Override
            public void onSheetClick(int index) {
                if (onGroupMemberClickListener == null) {
                    return;
                }
                if (index == 0) {
                    onGroupMemberClickListener.onShowInfo(groupMemberInfo);
                } else if (index == 1) {
                    onGroupMemberClickListener.onAdminRoleChanged(groupMemberInfo);
                } else if (index == 2) {
                    onGroupMemberClickListener.onDelete(groupMemberInfo);
                }
            }
        });
        sheet.show();
    }

    public void setGroupMemberListener(IGroupMemberListener listener) {
        this.groupMemberListener = listener;
    }

    public void setOnGroupMemberClickListener(OnGroupMemberClickListener onGroupMemberClickListener) {
        this.onGroupMemberClickListener = onGroupMemberClickListener;
    }

    public void setPresenter(GroupInfoPresenter presenter) {
        this.presenter = presenter;
        mAdapter.setPresenter(presenter);
    }

    public static class SelectedAdapter extends RecyclerView.Adapter<SelectedAdapter.SelectedViewHolder> {
        private List<GroupMemberInfo> mMembers;

        public void setMembers(List<GroupMemberInfo> mMembers) {
            this.mMembers = mMembers;
        }

        @NonNull
        @Override
        public SelectedViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new SelectedViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.group_member_selected_item, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull SelectedViewHolder holder, int position) {
            GlideEngine.loadImage(holder.userIconView, mMembers.get(position).getIconUrl());
        }

        @Override
        public int getItemCount() {
            if (mMembers == null) {
                return 0;
            }
            return mMembers.size();
        }

        public static class SelectedViewHolder extends RecyclerView.ViewHolder {
            public final RoundCornerImageView userIconView;

            public SelectedViewHolder(@NonNull View itemView) {
                super(itemView);
                userIconView = itemView.findViewById(R.id.ivAvatar);
                userIconView.setRadius(ScreenUtil.dip2px(20));
            }
        }
    }

    public interface OnSelectChangedListener {
        void onSelectChanged();
    }

    public abstract static class OnGroupMemberClickListener {
        public void onClick(GroupMemberInfo groupMemberInfo) {}

        public void onShowInfo(GroupMemberInfo groupMemberInfo) {}

        public void onAdminRoleChanged(GroupMemberInfo groupMemberInfo) {}

        public void onDelete(GroupMemberInfo groupMemberInfo) {}
    }
}
