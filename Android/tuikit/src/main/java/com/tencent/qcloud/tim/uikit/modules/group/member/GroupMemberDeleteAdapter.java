package com.tencent.qcloud.tim.uikit.modules.group.member;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.utils.BackgroundTasks;
import com.tencent.qcloud.tim.uikit.component.picture.imageEngine.impl.GlideEngine;

import java.util.ArrayList;
import java.util.List;


public class GroupMemberDeleteAdapter extends BaseAdapter {

    private List<GroupMemberInfo> mGroupMembers = new ArrayList<>();
    private List<GroupMemberInfo> mDelMembers = new ArrayList<>();
    private OnSelectChangedListener mSelectCallback;

    public GroupMemberDeleteAdapter() {
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
            view = LayoutInflater.from(TUIKit.getAppContext()).inflate(R.layout.group_member_del_adpater, viewGroup, false);
            holder = new MyViewHolder();
            holder.memberIcon = view.findViewById(R.id.group_member_icon);
            holder.memberName = view.findViewById(R.id.group_member_name);
            holder.delCheck = view.findViewById(R.id.group_member_del_check);
            view.setTag(holder);
        } else {
            holder = (MyViewHolder) view.getTag();
        }
        final GroupMemberInfo info = getItem(i);
        if (!TextUtils.isEmpty(info.getIconUrl()))
            GlideEngine.loadImage(holder.memberIcon, info.getIconUrl(), null);
        holder.memberName.setText(info.getAccount());
        holder.delCheck.setChecked(false);
        holder.delCheck.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    mDelMembers.add(info);
                } else {
                    mDelMembers.remove(info);
                }
                if (mSelectCallback != null) {
                    mSelectCallback.onSelectChanged(mDelMembers);
                }
            }
        });
        return view;
    }

    public void setDataSource(List<GroupMemberInfo> members) {
        if (members != null) {
            this.mGroupMembers = members;
            BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    notifyDataSetChanged();
                }
            });
        }
    }

    public void setOnSelectChangedListener(OnSelectChangedListener callback) {
        mSelectCallback = callback;
    }

    public void clear() {
        mDelMembers.clear();
    }

    private class MyViewHolder {
        private ImageView memberIcon;
        private TextView memberName;
        private CheckBox delCheck;
    }

    public interface OnSelectChangedListener {
        void onSelectChanged(List<GroupMemberInfo> mDelMembers);
    }
}
