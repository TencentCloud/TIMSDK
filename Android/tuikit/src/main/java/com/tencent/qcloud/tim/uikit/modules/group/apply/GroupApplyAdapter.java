package com.tencent.qcloud.tim.uikit.modules.group.apply;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.modules.chat.GroupChatManagerKit;
import com.tencent.qcloud.tim.uikit.modules.group.info.GroupInfo;
import com.tencent.qcloud.tim.uikit.modules.group.info.GroupInfoProvider;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.List;


public class GroupApplyAdapter extends BaseAdapter {

    private List<GroupApplyInfo> mGroupMembers = new ArrayList<>();
    private GroupInfoProvider mProvider;
    private OnItemClickListener mOnItemClickListener;

    public GroupApplyAdapter() {

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
            view = LayoutInflater.from(TUIKit.getAppContext()).inflate(R.layout.group_member_apply_adpater, viewGroup, false);
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
        holder.memberName.setText(info.getPendencyItem().getFromUser());
        holder.reason.setText(info.getPendencyItem().getRequestMsg());
        if (info.getStatus() == GroupApplyInfo.UNHANDLED) {
            holder.accept.setVisibility(View.VISIBLE);
            holder.accept.setText(R.string.accept);
            holder.accept.setBackground(TUIKit.getAppContext().getResources().getDrawable(R.color.bg_positive_btn));
            holder.accept.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    acceptApply(i, info);
                }
            });
            holder.refuse.setVisibility(View.VISIBLE);
            holder.refuse.setText(R.string.refuse);
            holder.refuse.setBackground(TUIKit.getAppContext().getResources().getDrawable(R.color.bg_negative_btn));
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
            holder.accept.setBackground(TUIKit.getAppContext().getResources().getDrawable(R.drawable.gray_btn_bg));
            holder.refuse.setVisibility(View.GONE);
        } else if (info.getStatus() == GroupApplyInfo.REFUSED) {
            holder.refuse.setVisibility(View.VISIBLE);
            holder.refuse.setClickable(false);
            holder.refuse.setText(R.string.refused);
            holder.refuse.setBackground(TUIKit.getAppContext().getResources().getDrawable(R.drawable.gray_btn_bg));
            holder.accept.setVisibility(View.GONE);
        }

        return view;
    }

    public void setOnItemClickListener(OnItemClickListener l) {
        mOnItemClickListener = l;
    }

    public void updateItemData(GroupApplyInfo info) {
        for (GroupApplyInfo i : mGroupMembers) {
            if (TextUtils.equals(i.getPendencyItem().getFromUser(), info.getPendencyItem().getFromUser())) {
                i.setStatus(info.getStatus());
                notifyDataSetChanged();
                break;
            }
        }
    }

    public void setDataSource(GroupInfo info) {
        mProvider = GroupChatManagerKit.getInstance().getProvider();
        mGroupMembers = mProvider.getApplyList();
    }


    public void acceptApply(final int position, final GroupApplyInfo item) {
        mProvider.acceptApply(item, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                notifyDataSetChanged();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }


    public void refuseApply(final int position, final GroupApplyInfo item) {
        mProvider.refuseApply(item, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                notifyDataSetChanged();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }

    public interface OnItemClickListener {
        void onItemClick(GroupApplyInfo info);
    }

    private class MyViewHolder {
        private ImageView memberIcon;
        private TextView memberName, reason;
        private Button accept, refuse;
    }

}
