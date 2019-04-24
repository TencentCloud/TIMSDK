package com.tencent.qcloud.uikit.business.chat.group.view.widget;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.uikit.TUIKit;
import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatManager;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupMemberInfo;
import com.tencent.qcloud.uikit.common.BackgroundTasks;
import com.tencent.qcloud.uikit.common.component.picture.imageEngine.impl.GlideEngine;

import java.util.ArrayList;
import java.util.List;


public class GroupMemberControlAdapter extends BaseAdapter {

    private List<GroupMemberInfo> mGroupMembers = new ArrayList<>();
    private GroupMemberControler mControler;

    public void setControler(GroupMemberControler controler) {
        mControler = controler;
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
            view = LayoutInflater.from(TUIKit.getAppContext()).inflate(R.layout.group_member_adpater, viewGroup, false);
            holder = new MyViewHolder();
            holder.memberIcon = view.findViewById(R.id.group_member_icon);
            holder.memberName = view.findViewById(R.id.group_member_name);
            view.setTag(holder);
        } else {
            holder = (MyViewHolder) view.getTag();
        }
        final GroupMemberInfo info = getItem(i);
        if (!TextUtils.isEmpty(info.getIconUrl()))
            GlideEngine.loadImage(holder.memberIcon, info.getIconUrl(), null);
        if (!TextUtils.isEmpty(info.getAccount()))
            holder.memberName.setText(info.getAccount());
        else
            holder.memberName.setText("");
        view.setOnClickListener(null);
        holder.memberIcon.setBackground(null);
        if (info.getMemberType() == -100) {
            holder.memberIcon.setImageResource(R.drawable.add_group_member);
            holder.memberIcon.setBackgroundResource(R.drawable.bottom_action_border);
            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mControler != null)
                        mControler.addMemberControl();
                }
            });
        } else if (info.getMemberType() == -101) {
            holder.memberIcon.setImageResource(R.drawable.del_group_member);
            holder.memberIcon.setBackgroundResource(R.drawable.bottom_action_border);
            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mControler != null)
                        mControler.delMemberControl();
                }
            });
        }

        return view;
    }

    public void setDataSource(List<GroupMemberInfo> members) {
        if (members != null) {
            int shootMemberCount = members.size() > 8 ? 8 : members.size();
            for (int i = 0; i < shootMemberCount; i++) {
                mGroupMembers.add(members.get(i));
            }
            GroupMemberInfo add = new GroupMemberInfo();
            add.setMemberType(-100);
            mGroupMembers.add(add);
            if (GroupChatManager.getInstance().getCurrentChatInfo().isOwner()) {
                GroupMemberInfo del = new GroupMemberInfo();
                del.setMemberType(-101);
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

    private class MyViewHolder {
        private ImageView memberIcon;
        private TextView memberName;
    }


}
