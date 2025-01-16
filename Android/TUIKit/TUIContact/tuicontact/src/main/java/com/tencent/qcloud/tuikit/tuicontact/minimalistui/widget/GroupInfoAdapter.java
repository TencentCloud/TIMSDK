package com.tencent.qcloud.tuikit.tuicontact.minimalistui.widget;

import android.content.res.Resources;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.timcommon.bean.GroupProfileBean;
import com.tencent.qcloud.tuikit.timcommon.component.gatherimage.ShadeImageView;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.GroupMemberGridListener;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class GroupInfoAdapter extends RecyclerView.Adapter<GroupInfoAdapter.GroupInfoMembersHolder> {
    private List<GroupMemberInfo> groupMemberBeans = new ArrayList<>();

    private GroupMemberGridListener groupMemberGridListener;
    private GroupProfileBean groupProfileBean;

    public void setGroupProfileBean(GroupProfileBean groupProfileBean) {
        this.groupProfileBean = groupProfileBean;
    }

    public GroupMemberInfo getItem(int i) {
        return groupMemberBeans.get(i);
    }

    @NonNull
    @Override
    public GroupInfoMembersHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.group_info_member_item_layout, parent, false);
        return new GroupInfoMembersHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull GroupInfoMembersHolder holder, int position) {
        final GroupMemberInfo groupMemberBean = getItem(position);
        GlideEngine.loadImage(holder.memberIcon, groupMemberBean.getFaceUrl());
        if (isSelf(groupMemberBean.getUserId())) {
            holder.memberName.setText(holder.itemView.getResources().getString(R.string.group_you));
            holder.rightArrow.setVisibility(View.GONE);
            holder.roleName.setText(getRoleString(holder.itemView.getResources(), groupMemberBean.getRole()));
            holder.itemView.setOnClickListener(null);
        } else {
            holder.memberName.setText(groupMemberBean.getDisplayName());
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (groupMemberGridListener != null) {
                        groupMemberGridListener.onGroupMemberClicked(groupMemberBean);
                    }
                }
            });
        }
        holder.memberIcon.setBackground(null);
        holder.memberIcon.setScaleType(ImageView.ScaleType.CENTER_CROP);
    }

    @Override
    public int getItemCount() {
        return groupMemberBeans.size();
    }

    public void setGroupMemberGridListener(GroupMemberGridListener groupMemberGridListener) {
        this.groupMemberGridListener = groupMemberGridListener;
    }

    public void setMemberList(List<GroupMemberInfo> members) {
        groupMemberBeans.clear();
        if (members == null || members.isEmpty()) {
            return;
        } else {
            boolean containSelf = false;
            for (GroupMemberInfo memberInfo : members) {
                if (isSelf(memberInfo.getUserId())) {
                    containSelf = true;
                    break;
                }
            }
            if (!containSelf) {
                GroupMemberInfo selfInfo = new GroupMemberInfo();
                selfInfo.setUserId(TUILogin.getLoginUser());
                selfInfo.setFaceUrl(TUIConfig.getSelfFaceUrl());
                selfInfo.setRole(groupProfileBean.getRoleInGroup());
                members.add(selfInfo);
            }
            Collections.sort(members, new Comparator<GroupMemberInfo>() {
                @Override
                public int compare(GroupMemberInfo o1, GroupMemberInfo o2) {
                    if (isSelf(o1.getUserId())) {
                        return -1;
                    } else if (isSelf(o2.getUserId())) {
                        return 1;
                    }
                    return 0;
                }
            });
            if (members.size() <= 3) {
                groupMemberBeans.addAll(members);
            } else {
                groupMemberBeans.addAll(members.subList(0, 3));
            }
        }
        notifyDataSetChanged();
    }

    public String getRoleString(Resources resources, int memberType) {
        if (groupProfileBean.isOwner()) {
            return resources.getString(R.string.group_owner_label);
        } else if (groupProfileBean.isAdmin()) {
            return resources.getString(R.string.group_manager_label);
        } else {
            return resources.getString(R.string.group_member_label);
        }
    }

    public boolean isSelf(String userId) {
        return TextUtils.equals(TUILogin.getLoginUser(), userId);
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
