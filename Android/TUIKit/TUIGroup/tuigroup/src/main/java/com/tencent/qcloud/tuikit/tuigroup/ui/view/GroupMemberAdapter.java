package com.tencent.qcloud.tuikit.tuigroup.ui.view;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.BackgroundTasks;
import com.tencent.qcloud.tuicore.util.PopWindowUtil;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupService;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuigroup.ui.interfaces.IGroupMemberChangedCallback;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupInfoPresenter;

import java.util.ArrayList;
import java.util.List;

public class GroupMemberAdapter extends RecyclerView.Adapter<GroupMemberAdapter.GroupMemberViewHodler> {

    private IGroupMemberChangedCallback mCallback;
    private GroupInfo mGroupInfo;
    private List<GroupMemberInfo> mGroupMembers = new ArrayList<>();

    private GroupInfoPresenter presenter;
    private boolean isSelectMode;

    private ArrayList<String> selectedMember = new ArrayList<>();

    public void setSelectMode(boolean selectMode) {
        isSelectMode = selectMode;
    }

    public ArrayList<String> getSelectedMember() {
        return selectedMember;
    }

    public void setPresenter(GroupInfoPresenter presenter) {
        this.presenter = presenter;
    }

    public void setMemberChangedCallback(IGroupMemberChangedCallback callback) {
        this.mCallback = callback;
    }

    @NonNull
    @Override
    public GroupMemberViewHodler onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.group_member_list_item, parent, false);
        return new GroupMemberViewHodler(view);
    }

    @Override
    public void onBindViewHolder(@NonNull GroupMemberViewHodler holder, int position) {
        final GroupMemberInfo info = mGroupMembers.get(position);
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

        if (isSelectMode) {
            holder.checkBox.setVisibility(View.VISIBLE);
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    holder.checkBox.setChecked(!holder.checkBox.isChecked());
                    if (holder.checkBox.isChecked()) {
                        selectedMember.add(info.getAccount());
                    } else {
                        selectedMember.remove(info.getAccount());
                    }
                }
            });

        } else {
            holder.itemView.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    if (!mGroupInfo.isOwner()) {
                        return false;
                    }
                    TextView delete = new TextView(holder.itemView.getContext());
                    delete.setText(R.string.group_remove_member);
                    int padding = ScreenUtil.getPxByDp(10);
                    delete.setPadding(padding, padding, padding, padding);
                    delete.setBackgroundResource(R.drawable.text_border);
                    int location[] = new int[2];
                    v.getLocationInWindow(location);
                    final PopupWindow window = PopWindowUtil.popupWindow(delete, holder.itemView, location[0], location[1] + v.getMeasuredHeight() / 3);
                    delete.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            List<GroupMemberInfo> dels = new ArrayList<>();
                            dels.add(info);
                            if (presenter == null) {
                                return;
                            }
                            presenter.removeGroupMembers(mGroupInfo, dels, new IUIKitCallback() {
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
                                    ToastUtil.toastLongMessage(TUIGroupService.getAppContext().getString(R.string.remove_fail_tip) + ":errCode=" + errCode);
                                }
                            });
                            window.dismiss();
                        }
                    });
                    return false;
                }
            });

            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Bundle bundle = new Bundle();
                    bundle.putString("chatId", info.getAccount());
                    TUICore.startActivity("FriendProfileActivity", bundle);
                }
            });
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
            this.mGroupMembers = groupInfo.getMemberDetails();
            BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    notifyDataSetChanged();
                }
            });
        }
    }

    protected class GroupMemberViewHodler extends RecyclerView.ViewHolder {
        private ImageView memberIcon;
        private TextView memberName;
        private CheckBox checkBox;

        public GroupMemberViewHodler(@NonNull View itemView) {
            super(itemView);
            checkBox = itemView.findViewById(R.id.group_member_check_box);
            memberIcon = itemView.findViewById(R.id.group_member_icon);
            memberName = itemView.findViewById(R.id.group_member_name);
        }
    }
}
