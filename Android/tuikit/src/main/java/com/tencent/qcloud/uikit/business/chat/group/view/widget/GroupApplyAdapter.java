package com.tencent.qcloud.uikit.business.chat.group.view.widget;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.uikit.TUIKit;
import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupApplyInfo;
import com.tencent.qcloud.uikit.business.chat.group.presenter.GroupApplyPresenter;

import java.util.ArrayList;
import java.util.List;


public class GroupApplyAdapter extends BaseAdapter implements GroupApplyCallback {
    private List<GroupApplyInfo> mGroupMembers = new ArrayList<>();
    private GroupApplyPresenter mPresenter;

    public GroupApplyAdapter() {
        mPresenter = new GroupApplyPresenter(this);
        setDataSource(mPresenter.getApplyInfos());
    }

    @Override
    public int getCount() {
        return mGroupMembers.size();
    }

    @Override
    public GroupApplyInfo getItem(int i) {
        return mGroupMembers.get(i);
    }

    @Override
    public long getItemId(int i) {
        return 0;
    }

    @Override
    public View getView(final int i, View view, ViewGroup viewGroup) {
        MyViewHolder holder;
        if (view == null) {
            view = LayoutInflater.from(TUIKit.getAppContext()).inflate(R.layout.group_member_apply_adpater, viewGroup, false);
            holder = new MyViewHolder();
            holder.memberIcon = view.findViewById(R.id.group_apply_member_icon);
            holder.memberName = view.findViewById(R.id.group_apply_member_name);
            holder.reason = view.findViewById(R.id.group_apply_reason);
            holder.accept = view.findViewById(R.id.group_apply_accept);
            holder.refuse = view.findViewById(R.id.group_apply_refuse);
            view.setTag(holder);
        } else {
            holder = (MyViewHolder) view.getTag();
        }
        final GroupApplyInfo info = getItem(i);
        holder.memberName.setText(info.getPendencyItem().getFromUser());
        holder.reason.setText(info.getPendencyItem().getRequestMsg());
        if (info.getStatus() == 0) {
            holder.accept.setVisibility(View.VISIBLE);
            holder.accept.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    mPresenter.acceptApply(i, info);
                }
            });
            holder.refuse.setVisibility(View.VISIBLE);
            holder.refuse.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    mPresenter.refuseApply(i, info);
                }
            });
        } else if (info.getStatus() == 1) {
            holder.accept.setVisibility(View.VISIBLE);
            holder.accept.setClickable(false);
            holder.accept.setText(R.string.accepted);
            holder.refuse.setVisibility(View.GONE);
        } else if (info.getStatus() == -1) {
            holder.refuse.setVisibility(View.VISIBLE);
            holder.refuse.setClickable(false);
            holder.refuse.setText(R.string.refused);
            holder.accept.setVisibility(View.GONE);
        }

        return view;
    }

    public void setDataSource(List<GroupApplyInfo> members) {
        this.mGroupMembers = members;
    }

    @Override
    public void onAccept(int position, GroupApplyInfo item) {
        item.setStatus(1);
        notifyDataSetChanged();
    }

    @Override
    public void onRefuse(int position, GroupApplyInfo item) {
        item.setStatus(-1);
        notifyDataSetChanged();
    }

    private class MyViewHolder {
        private ImageView memberIcon;
        private TextView memberName, reason;
        private Button accept, refuse;
    }

}
