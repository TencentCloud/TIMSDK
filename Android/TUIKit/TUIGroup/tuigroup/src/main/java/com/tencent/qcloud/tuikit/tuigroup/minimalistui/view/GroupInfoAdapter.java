package com.tencent.qcloud.tuikit.tuigroup.minimalistui.view;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.component.gatherimage.ShadeImageView;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.util.BackgroundTasks;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuigroup.minimalistui.interfaces.IGroupMemberListener;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupInfoPresenter;

import java.util.ArrayList;
import java.util.List;


public class GroupInfoAdapter extends BaseAdapter {

    private static final int ADD_TYPE = -100;
    private static final int DEL_TYPE = -101;
    private static final int OWNER_PRIVATE_MAX_LIMIT = 8;  //讨论组,owner可以添加成员和删除成员，
    private static final int OWNER_PUBLIC_MAX_LIMIT = 9;   //公开群,owner不可以添加成员，但是可以删除成员
    private static final int OWNER_CHATROOM_MAX_LIMIT = 9; //聊天室,owner不可以添加成员，但是可以删除成员
    private static final int OWNER_COMMUNITY_MAX_LIMIT = 8; //社群,owner可以添加成员和删除成员，
    private static final int NORMAL_PRIVATE_MAX_LIMIT = 9; //讨论组,普通人可以添加成员
    private static final int NORMAL_PUBLIC_MAX_LIMIT = 10;  //公开群,普通人没有权限添加成员和删除成员
    private static final int NORMAL_CHATROOM_MAX_LIMIT = 10; //聊天室,普通人没有权限添加成员和删除成员
    private static final int NORMAL_COMMUNITY_MAX_LIMIT = 9; //社群,普通人可以添加成员

    private List<GroupMemberInfo> mGroupMembers = new ArrayList<>();
    private IGroupMemberListener mTailListener;
    private GroupInfo mGroupInfo;

    private GroupInfoPresenter presenter;

    public void setPresenter(GroupInfoPresenter presenter) {
        this.presenter = presenter;
    }

    public void setManagerCallBack(IGroupMemberListener listener) {
        mTailListener = listener;
    }

    @Override
    public int getCount() {
        return mGroupMembers.size();
    }

    @Override
    public GroupMemberInfo getItem(int i) {
        return mGroupMembers.get(i);
    }

    @Override
    public long getItemId(int i) {
        return 0;
    }

    @Override
    public View getView(final int i, View view, final ViewGroup viewGroup) {
        MyViewHolder holder;
        if (view == null) {
            view = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.group_member_item_layout, viewGroup, false);
            holder = new MyViewHolder();
            holder.memberIcon = view.findViewById(R.id.group_member_icon);
            holder.memberIcon.setRadius(ScreenUtil.dip2px(24));
            holder.memberName = view.findViewById(R.id.group_member_name);
            view.setTag(holder);
        } else {
            holder = (MyViewHolder) view.getTag();
        }
        final GroupMemberInfo info = getItem(i);
        GlideEngine.loadImage(holder.memberIcon, info.getIconUrl());
        // 显示优先级 群名片->昵称->账号
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
        view.setOnClickListener(null);
        holder.memberIcon.setBackground(null);
        holder.memberIcon.setScaleType(ImageView.ScaleType.CENTER_CROP);
        if (info.getMemberType() == ADD_TYPE) {
            holder.memberIcon.setImageResource(R.drawable.add_group_member);
            holder.memberIcon.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
            holder.memberIcon.setBackgroundResource(R.drawable.group_minimalist_add_border);
            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mTailListener != null) {
                        mTailListener.forwardAddMember(mGroupInfo);
                    }
                }
            });
        } else if (info.getMemberType() == DEL_TYPE) {
            holder.memberIcon.setImageResource(R.drawable.del_group_member);
            holder.memberIcon.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
            holder.memberIcon.setBackgroundResource(R.drawable.bottom_action_border);
            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mTailListener != null) {
                        mTailListener.forwardDeleteMember(mGroupInfo);
                    }
                }
            });
        }
        return view;
    }

    public void setDataSource(GroupInfo info) {
        mGroupInfo = info;
        mGroupMembers.clear();
        List<GroupMemberInfo> members = info.getMemberDetails();
        if (members != null) {
            int shootMemberCount = 0;
            if (TextUtils.equals(info.getGroupType(), TUIConstants.GroupType.TYPE_PRIVATE)
                    || TextUtils.equals(info.getGroupType(), TUIConstants.GroupType.TYPE_WORK)) {
                if (info.isOwner()) {
                    shootMemberCount = members.size() > OWNER_PRIVATE_MAX_LIMIT ? OWNER_PRIVATE_MAX_LIMIT : members.size();
                } else {
                    shootMemberCount = members.size() > NORMAL_PRIVATE_MAX_LIMIT ? NORMAL_PRIVATE_MAX_LIMIT : members.size();
                }
            } else if (TextUtils.equals(info.getGroupType(), TUIConstants.GroupType.TYPE_PUBLIC)) {
                if (info.isOwner()) {
                    shootMemberCount = members.size() > OWNER_PUBLIC_MAX_LIMIT ? OWNER_PUBLIC_MAX_LIMIT : members.size();
                } else {
                    shootMemberCount = members.size() > NORMAL_PUBLIC_MAX_LIMIT ? NORMAL_PUBLIC_MAX_LIMIT : members.size();
                }
            } else if (TextUtils.equals(info.getGroupType(), TUIConstants.GroupType.TYPE_CHAT_ROOM)
                    || TextUtils.equals(info.getGroupType(), TUIConstants.GroupType.TYPE_MEETING)) {
                if (info.isOwner()) {
                    shootMemberCount = members.size() > OWNER_CHATROOM_MAX_LIMIT ? OWNER_CHATROOM_MAX_LIMIT : members.size();
                } else {
                    shootMemberCount = members.size() > NORMAL_CHATROOM_MAX_LIMIT ? NORMAL_CHATROOM_MAX_LIMIT : members.size();
                }
            } else if (TextUtils.equals(info.getGroupType(), TUIConstants.GroupType.TYPE_COMMUNITY)) {
                if (info.isOwner()) {
                    shootMemberCount = members.size() > OWNER_COMMUNITY_MAX_LIMIT ? OWNER_COMMUNITY_MAX_LIMIT : members.size();
                } else {
                    shootMemberCount = members.size() > NORMAL_COMMUNITY_MAX_LIMIT ? NORMAL_COMMUNITY_MAX_LIMIT : members.size();
                }
            }

            for (int i = 0; i < shootMemberCount; i++) {
                mGroupMembers.add(members.get(i));
            }
            if (TextUtils.equals(info.getGroupType(), TUIConstants.GroupType.TYPE_PRIVATE)
                    || TextUtils.equals(info.getGroupType(), TUIConstants.GroupType.TYPE_WORK)
                    || TextUtils.equals(info.getGroupType(), TUIConstants.GroupType.TYPE_COMMUNITY)) {
                // 公开群/聊天室 只有APP管理员可以邀请他人入群
                GroupMemberInfo add = new GroupMemberInfo();
                add.setMemberType(ADD_TYPE);
                mGroupMembers.add(add);
            }
            GroupMemberInfo self = null;
            for (int i = 0; i < mGroupMembers.size(); i++) {
                GroupMemberInfo memberInfo = mGroupMembers.get(i);
                if (isSelf(memberInfo.getAccount())) {
                    self = memberInfo;
                    break;
                }
            }
            if (info.isOwner() || (self != null && isAdmin(self.getMemberType()))) {
                GroupMemberInfo del = new GroupMemberInfo();
                del.setMemberType(DEL_TYPE);
                mGroupMembers.add(del);
            }
            BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    notifyDataSetChanged();
                }
            });
        }

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

    private class MyViewHolder {
        private ShadeImageView memberIcon;
        private TextView memberName;
    }


}
