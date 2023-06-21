package com.tencent.qcloud.tuikit.tuigroup.minimalistui.widget;

import android.content.res.Resources;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.timcommon.component.gatherimage.ShadeImageView;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupInfoPresenter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class GroupInfoAdapter extends RecyclerView.Adapter<GroupInfoAdapter.GroupInfoMembersHolder> {
    private List<GroupMemberInfo> mGroupMembers = new ArrayList<>();

    private GroupInfoPresenter presenter;
    private GroupMemberLayout.OnGroupMemberClickListener onGroupMemberClickListener;

    public void setPresenter(GroupInfoPresenter presenter) {
        this.presenter = presenter;
    }

    public GroupMemberInfo getItem(int i) {
        return mGroupMembers.get(i);
    }

    public void setOnGroupMemberClickListener(GroupMemberLayout.OnGroupMemberClickListener onGroupMemberClickListener) {
        this.onGroupMemberClickListener = onGroupMemberClickListener;
    }

    @NonNull
    @Override
    public GroupInfoMembersHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.group_info_member_item_layout, parent, false);
        return new GroupInfoMembersHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull GroupInfoMembersHolder holder, int position) {
        final GroupMemberInfo info = getItem(position);
        GlideEngine.loadImage(holder.memberIcon, info.getIconUrl());
        if (isSelf(info.getAccount())) {
            holder.memberName.setText(holder.itemView.getResources().getString(R.string.group_you));
            holder.rightArrow.setVisibility(View.GONE);
            holder.roleName.setText(getRoleString(holder.itemView.getResources(), info.getMemberType()));
            holder.itemView.setOnClickListener(null);
        } else {
            holder.memberName.setText(info.getDisplayName());
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onGroupMemberClickListener != null) {
                        onGroupMemberClickListener.onClick(info);
                    }
                }
            });
        }
        holder.memberIcon.setBackground(null);
        holder.memberIcon.setScaleType(ImageView.ScaleType.CENTER_CROP);
    }

    @Override
    public int getItemCount() {
        return mGroupMembers.size();
    }

    public void setDataSource(GroupInfo info) {
        mGroupMembers.clear();
        List<GroupMemberInfo> members = info.getMemberDetails();
        if (members == null || members.isEmpty()) {
            return;
        } else {
            boolean containSelf = false;
            for (GroupMemberInfo memberInfo : members) {
                if (isSelf(memberInfo.getAccount())) {
                    containSelf = true;
                    break;
                }
            }
            if (!containSelf) {
                GroupMemberInfo selfInfo = new GroupMemberInfo();
                selfInfo.setAccount(TUILogin.getLoginUser());
                selfInfo.setIconUrl(TUIConfig.getSelfFaceUrl());
                selfInfo.setMemberType(info.getRole());
                members.add(selfInfo);
            }
            Collections.sort(members, new Comparator<GroupMemberInfo>() {
                @Override
                public int compare(GroupMemberInfo o1, GroupMemberInfo o2) {
                    if (isSelf(o1.getAccount())) {
                        return -1;
                    } else if (isSelf(o2.getAccount())) {
                        return 1;
                    }
                    return 0;
                }
            });
            if (members.size() <= 3) {
                mGroupMembers.addAll(members);
            } else {
                mGroupMembers.addAll(members.subList(0, 3));
            }
        }
        ThreadUtils.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                notifyDataSetChanged();
            }
        });
    }

    public String getRoleString(Resources resources, int memberType) {
        if (isOwner(memberType)) {
            return resources.getString(R.string.group_owner_label);
        } else if (isAdmin(memberType)) {
            return resources.getString(R.string.group_manager_label);
        } else {
            return resources.getString(R.string.group_member_label);
        }
    }

    public boolean isOwner(int memberType) {
        if (presenter != null) {
            return presenter.isOwner(memberType);
        }
        return false;
    }

    public boolean isAdmin(int memberType) {
        if (presenter != null) {
            return presenter.isAdmin(memberType);
        }
        return false;
    }

    public boolean isSelf(String userId) {
        if (presenter != null) {
            return presenter.isSelf(userId);
        }
        return false;
    }

    public static class GroupInfoMembersHolder extends RecyclerView.ViewHolder {
        private final ShadeImageView memberIcon;
        private final TextView memberName;
        private final TextView roleName;
        private final ImageView rightArrow;

        public GroupInfoMembersHolder(@NonNull View itemView) {
            super(itemView);
            memberIcon = itemView.findViewById(R.id.group_member_icon);
            memberIcon.setRadius(ScreenUtil.dip2px(24));
            memberName = itemView.findViewById(R.id.group_member_name);
            roleName = itemView.findViewById(R.id.role_text);
            rightArrow = itemView.findViewById(R.id.rightArrow);
        }
    }
}
