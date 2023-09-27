package com.tencent.qcloud.tuikit.tuigroup.minimalistui.widget;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.timcommon.component.gatherimage.ShadeImageView;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuigroup.minimalistui.interfaces.IGroupMemberChangedCallback;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupInfoPresenter;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class GroupMemberAdapter extends RecyclerView.Adapter<GroupMemberAdapter.GroupMemberViewHodler> {
    private IGroupMemberChangedCallback mCallback;
    private GroupInfo mGroupInfo;
    private List<GroupMemberInfo> mGroupMembers = new ArrayList<>();
    private List<GroupMemberInfo> selectedGroupMemberInfos = new ArrayList<>();

    private GroupInfoPresenter presenter;
    private boolean isSelectMode;
    private GroupMemberLayout.OnSelectChangedListener onSelectChangedListener;
    private ArrayList<String> selectedMember = new ArrayList<>();
    private ArrayList<String> excludeList;
    private ArrayList<String> alreadySelectedList;

    private GroupMemberLayout.OnGroupMemberClickListener onGroupMemberClickListener;

    public void setSelectMode(boolean selectMode) {
        isSelectMode = selectMode;
    }

    public ArrayList<String> getSelectedMember() {
        return selectedMember;
    }

    public List<GroupMemberInfo> getSelectedMemberInfoList() {
        return selectedGroupMemberInfos;
    }

    public void setPresenter(GroupInfoPresenter presenter) {
        this.presenter = presenter;
    }

    public void setMemberChangedCallback(IGroupMemberChangedCallback callback) {
        this.mCallback = callback;
    }

    public void setExcludeList(ArrayList<String> excludeList) {
        this.excludeList = excludeList;
    }

    public void setAlreadySelectedList(ArrayList<String> alreadySelectedList) {
        this.alreadySelectedList = alreadySelectedList;
    }

    public void setOnSelectChangedListener(GroupMemberLayout.OnSelectChangedListener onSelectChangedListener) {
        this.onSelectChangedListener = onSelectChangedListener;
    }

    public void setOnGroupMemberClickListener(GroupMemberLayout.OnGroupMemberClickListener onGroupMemberClickListener) {
        this.onGroupMemberClickListener = onGroupMemberClickListener;
    }

    @NonNull
    @Override
    public GroupMemberViewHodler onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.group_minimalist_member_list_item, parent, false);
        return new GroupMemberViewHodler(view);
    }

    @Override
    public void onBindViewHolder(@NonNull GroupMemberViewHodler holder, int position) {
        final GroupMemberInfo info = mGroupMembers.get(position);
        GlideEngine.loadImage(holder.memberIcon, info.getIconUrl());
        if (!TextUtils.isEmpty(info.getNameCard())) {
            holder.memberName.setText(info.getNameCard());
        } else {
            if (!TextUtils.isEmpty(info.getNickName())) {
                holder.memberName.setText(info.getNickName());
            } else {
                if (!TextUtils.isEmpty(info.getAccount())) {
                    holder.memberName.setText(info.getAccount());
                } else {
                    holder.memberName.setText("");
                }
            }
        }

        if (isSelectMode) {
            holder.checkBox.setVisibility(View.VISIBLE);
            holder.checkBox.setChecked(info.isSelected());
            holder.arrowRight.setVisibility(View.GONE);
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    holder.checkBox.setChecked(!holder.checkBox.isChecked());
                    if (holder.checkBox.isChecked()) {
                        info.setSelected(true);
                        selectedMember.add(info.getAccount());
                        selectedGroupMemberInfos.add(info);
                    } else {
                        info.setSelected(false);
                        selectedMember.remove(info.getAccount());
                        selectedGroupMemberInfos.remove(info);
                    }
                    if (onSelectChangedListener != null) {
                        onSelectChangedListener.onSelectChanged();
                    }
                }
            });
            holder.memberRoleTv.setVisibility(View.GONE);
        } else {
            if (presenter.isSelf(info.getAccount())) {
                holder.itemView.setOnClickListener(null);
                holder.arrowRight.setVisibility(View.GONE);
            } else {
                holder.arrowRight.setVisibility(View.VISIBLE);
                holder.itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (onGroupMemberClickListener != null) {
                            onGroupMemberClickListener.onClick(info);
                        }
                    }
                });
            }
            if (presenter.isOwner(info.getMemberType())) {
                holder.memberRoleTv.setVisibility(View.VISIBLE);
                holder.memberRoleTv.setText(holder.itemView.getResources().getString(R.string.group_owner_label));
            } else if (presenter.isAdmin(info.getMemberType())) {
                holder.memberRoleTv.setVisibility(View.VISIBLE);
                holder.memberRoleTv.setText(holder.itemView.getResources().getString(R.string.group_manager_label));
            } else {
                holder.memberRoleTv.setVisibility(View.GONE);
            }
        }

        setAlreadySelected(holder, info);
    }

    private void setAlreadySelected(GroupMemberViewHodler holder, GroupMemberInfo memberInfo) {
        if (alreadySelectedList != null && alreadySelectedList.contains(memberInfo.getAccount())) {
            holder.checkBox.setChecked(true);
            holder.itemView.setEnabled(false);
            holder.checkBox.setEnabled(false);
        } else {
            holder.itemView.setEnabled(true);
            holder.checkBox.setEnabled(true);
            holder.checkBox.setSelected(memberInfo.isSelected());
        }
    }

    @Override
    public int getItemCount() {
        if (mGroupMembers == null) {
            return 0;
        }
        return mGroupMembers.size();
    }

    public void setDataSource(GroupInfo groupInfo) {
        if (groupInfo != null) {
            mGroupInfo = groupInfo;
            mGroupMembers.clear();
            if (excludeList == null || excludeList.isEmpty()) {
                mGroupMembers.addAll(groupInfo.getMemberDetails());
            } else {
                for (GroupMemberInfo groupMemberInfo : groupInfo.getMemberDetails()) {
                    if (excludeList.contains(groupMemberInfo.getAccount())) {
                        continue;
                    }
                    mGroupMembers.add(groupMemberInfo);
                }
            }
            ThreadUtils.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    notifyDataSetChanged();
                }
            });
        }
    }

    public void deleteMember(List<String> members) {
        if (members == null || members.isEmpty()) {
            return;
        }
        Iterator<GroupMemberInfo> iterator = mGroupMembers.listIterator();
        while (iterator.hasNext()) {
            if (members.contains(iterator.next().getAccount())) {
                iterator.remove();
            }
        }
        notifyDataSetChanged();
    }

    public void memberChanged(GroupMemberInfo groupMemberInfo) {
        int index = mGroupMembers.indexOf(groupMemberInfo);
        if (index != -1) {
            notifyItemChanged(index);
        }
    }

    protected class GroupMemberViewHodler extends RecyclerView.ViewHolder {
        private ShadeImageView memberIcon;
        private TextView memberName;
        private TextView memberRoleTv;
        private CheckBox checkBox;
        private View arrowRight;

        public GroupMemberViewHodler(@NonNull View itemView) {
            super(itemView);
            arrowRight = itemView.findViewById(R.id.rightArrow);
            arrowRight.getBackground().setAutoMirrored(true);
            checkBox = itemView.findViewById(R.id.group_member_check_box);
            memberIcon = itemView.findViewById(R.id.group_member_icon);
            memberIcon.setRadius(ScreenUtil.dip2px(20));
            memberName = itemView.findViewById(R.id.group_member_name);
            memberRoleTv = itemView.findViewById(R.id.member_role_tv);
        }
    }
}
