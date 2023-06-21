package com.tencent.qcloud.tuikit.tuigroup.classicui.widget;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import com.tencent.imsdk.v2.V2TIMGroupApplication;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupService;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupApplyInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupApplyPresenter;
import java.util.ArrayList;
import java.util.List;

public class GroupApplyAdapter extends BaseAdapter {
    private List<GroupApplyInfo> mGroupMembers = new ArrayList<>();
    private OnItemClickListener mOnItemClickListener;
    private GroupApplyPresenter presenter;

    public GroupApplyAdapter() {}

    public void setPresenter(GroupApplyPresenter presenter) {
        this.presenter = presenter;
    }

    @Override
    public int getCount() {
        return mGroupMembers.size();
    }

    public int getUnHandledSize() {
        int total = 0;
        for (GroupApplyInfo i : mGroupMembers) {
            if (i.getStatus() == GroupApplyInfo.UNHANDLED) {
                total++;
            }
        }
        return total;
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
        final GroupApplyInfo info = getItem(i);
        if (view == null) {
            view = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.group_member_apply_adpater, viewGroup, false);
            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mOnItemClickListener != null && info.getStatus() == GroupApplyInfo.UNHANDLED) {
                        mOnItemClickListener.onItemClick(info);
                    }
                }
            });
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

        if (info.getGroupApplication().getApplicationType() == V2TIMGroupApplication.V2TIM_GROUP_INVITE_APPLICATION_NEED_APPROVED_BY_ADMIN) {
            holder.memberName.setText(info.getGroupApplication().getFromUser());
            holder.reason.setText(view.getResources().getString(R.string.invite) + " " + info.getGroupApplication().getToUser());
        } else {
            if (TextUtils.isEmpty(info.getFromUserNickName())) {
                holder.memberName.setText(info.getFromUserID());
            } else {
                holder.memberName.setText(info.getFromUserNickName());
            }
            holder.reason.setText(info.getAddWording());
        }
        GlideEngine.loadUserIcon(holder.memberIcon, info.getFromUserFaceUrl(), ScreenUtil.dip2px(4));

        if (info.getStatus() == GroupApplyInfo.UNHANDLED) {
            holder.accept.setVisibility(View.VISIBLE);
            holder.accept.setText(R.string.accept);
            holder.accept.setBackground(TUIGroupService.getAppContext().getResources().getDrawable(R.drawable.group_bg_positive_btn));
            holder.accept.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    acceptApply(i, info);
                }
            });
            holder.refuse.setVisibility(View.VISIBLE);
            holder.refuse.setText(R.string.refuse);
            holder.refuse.setBackground(TUIGroupService.getAppContext().getResources().getDrawable(R.drawable.group_bg_negative_btn));
            holder.refuse.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    refuseApply(i, info);
                }
            });
        } else if (info.getStatus() == GroupApplyInfo.APPLIED) {
            holder.accept.setVisibility(View.VISIBLE);
            holder.accept.setClickable(false);
            holder.accept.setText(R.string.accepted);
            holder.accept.setBackground(TUIGroupService.getAppContext().getResources().getDrawable(R.drawable.gray_btn_bg));
            holder.refuse.setVisibility(View.GONE);
        } else if (info.getStatus() == GroupApplyInfo.REFUSED) {
            holder.refuse.setVisibility(View.VISIBLE);
            holder.refuse.setClickable(false);
            holder.refuse.setText(R.string.refused);
            holder.refuse.setBackground(TUIGroupService.getAppContext().getResources().getDrawable(R.drawable.gray_btn_bg));
            holder.accept.setVisibility(View.GONE);
        }

        return view;
    }

    public void setOnItemClickListener(OnItemClickListener l) {
        mOnItemClickListener = l;
    }

    public void updateItemData(GroupApplyInfo info) {
        for (GroupApplyInfo i : mGroupMembers) {
            if (TextUtils.equals(i.getGroupApplication().getFromUser(), info.getGroupApplication().getFromUser())) {
                i.setStatus(info.getStatus());
                notifyDataSetChanged();
                break;
            }
        }
    }

    public void setDataSource(GroupInfo info) {
        presenter.loadGroupApplies();
    }

    public void setDataSource(List<GroupApplyInfo> applyInfoList) {
        mGroupMembers = applyInfoList;
        notifyDataSetChanged();
    }

    public void acceptApply(final int position, final GroupApplyInfo item) {
        if (presenter == null) {
            return;
        }
        presenter.acceptApply(item, null);
    }

    public void refuseApply(final int position, final GroupApplyInfo item) {
        if (presenter == null) {
            return;
        }
        presenter.refuseApply(item, null);
    }

    public interface OnItemClickListener {
        void onItemClick(GroupApplyInfo info);
    }

    private class MyViewHolder {
        private ImageView memberIcon;
        private TextView memberName;
        private TextView reason;
        private TextView accept;
        private TextView refuse;
    }
}
