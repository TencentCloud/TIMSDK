package com.tencent.qcloud.tim.uikit.modules.group.member;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.utils.BackgroundTasks;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.component.picture.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tim.uikit.modules.group.info.GroupInfo;
import com.tencent.qcloud.tim.uikit.modules.group.info.GroupInfoProvider;
import com.tencent.qcloud.tim.uikit.utils.PopWindowUtil;
import com.tencent.qcloud.tim.uikit.utils.ScreenUtil;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.List;


public class GroupMemberManagerAdapter extends BaseAdapter {

    private IGroupMemberChangedCallback mCallback;
    private GroupInfo mGroupInfo;
    private List<GroupMemberInfo> mGroupMembers = new ArrayList<>();

    public void setMemberChangedCallback(IGroupMemberChangedCallback callback) {
        this.mCallback = callback;
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
        holder.memberName.setText(info.getAccount());
        view.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                if (!mGroupInfo.isOwner())
                    return false;
                TextView delete = new TextView(viewGroup.getContext());
                delete.setText(R.string.group_remove_member);
                int padding = ScreenUtil.getPxByDp(10);
                delete.setPadding(padding, padding, padding, padding);
                delete.setBackgroundResource(R.drawable.text_border);
                int location[] = new int[2];
                v.getLocationInWindow(location);
                final PopupWindow window = PopWindowUtil.popupWindow(delete, viewGroup, location[0], location[1] + v.getMeasuredHeight() / 3);
                delete.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        List<GroupMemberInfo> dels = new ArrayList<>();
                        dels.add(info);
                        GroupInfoProvider provider = new GroupInfoProvider();
                        provider.loadGroupInfo(mGroupInfo);
                        provider.removeGroupMembers(dels, new IUIKitCallBack() {
                            @Override
                            public void onSuccess(Object data) {
                                mGroupMembers.remove(info);
                                notifyDataSetChanged();
                                if (mCallback != null) {
                                    mCallback.onMemberRemoved(info);
                                }
                            }

                            @Override
                            public void onError(String module, int errCode, String errMsg) {
                                ToastUtil.toastLongMessage("移除成员失败:errCode=" + errCode);
                            }
                        });
                        window.dismiss();
                    }
                });
                return false;
            }
        });
        return view;
    }

    public void setDataSource(GroupInfo groupInfo) {
        if (groupInfo != null) {
            mGroupInfo = groupInfo;
            this.mGroupMembers = groupInfo.getMemberDetails();
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
