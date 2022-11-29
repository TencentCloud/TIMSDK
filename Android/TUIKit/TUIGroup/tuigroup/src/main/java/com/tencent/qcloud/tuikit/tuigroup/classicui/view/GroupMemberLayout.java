package com.tencent.qcloud.tuikit.tuigroup.classicui.view;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuigroup.classicui.interfaces.IGroupMemberChangedCallback;
import com.tencent.qcloud.tuikit.tuigroup.classicui.interfaces.IGroupMemberListener;
import com.tencent.qcloud.tuikit.tuigroup.component.BottomSelectSheet;
import com.tencent.qcloud.tuikit.tuigroup.interfaces.IGroupMemberLayout;
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

        selectArea = findViewById(R.id.select_area);
        selectedList = findViewById(R.id.selected_list);
        selectedListAdapter = new SelectedAdapter();
        selectedList.setLayoutManager(new LinearLayoutManager(getContext(), RecyclerView.HORIZONTAL, false));
        selectedList.setAdapter(selectedListAdapter);

        confirmButton = findViewById(R.id.confirm_button);
        confirmButton.setOnClickListener(new View.OnClickListener() {
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
        public void onBindViewHolder(@NonNull SelectedAdapter.SelectedViewHolder holder, int position) {
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
            public final ImageView userIconView;
            public SelectedViewHolder(@NonNull View itemView) {
                super(itemView);
                userIconView = (ImageView) itemView.findViewById(R.id.ivAvatar);
            }
        }
    }

    public interface OnSelectChangedListener {
        void onSelectChanged();
    }

}
