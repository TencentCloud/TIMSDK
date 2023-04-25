package com.tencent.qcloud.tuikit.tuicallkit.extensions.inviteuser;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader;

import java.util.ArrayList;
import java.util.List;

public class SelectGroupMemberAdapter extends RecyclerView.Adapter<SelectGroupMemberAdapter.GroupMemberViewHolder> {
    private Context               mContext;
    private List<GroupMemberInfo> mGroupMemberList = new ArrayList<>();

    public void setDataSource(List<GroupMemberInfo> userList) {
        mGroupMemberList = userList;
    }

    @NonNull
    @Override
    public GroupMemberViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        mContext = parent.getContext();
        View view = LayoutInflater.from(mContext).inflate(R.layout.tuicallkit_group_user_list_item, parent, false);
        return new GroupMemberViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull GroupMemberViewHolder holder, int position) {
        GroupMemberInfo userInfo = mGroupMemberList.get(position);
        holder.itemView.setOnClickListener(v -> {
            holder.mCheckBox.setChecked(!holder.mCheckBox.isChecked());
            userInfo.isSelected = holder.mCheckBox.isChecked();
        });
        holder.layoutView(userInfo);
    }

    @Override
    public int getItemCount() {
        return mGroupMemberList.size();
    }

    class GroupMemberViewHolder extends RecyclerView.ViewHolder {
        private ImageView mImageAvatar;
        private TextView  mTextName;
        private TextView  mTextHint;
        private CheckBox  mCheckBox;

        public GroupMemberViewHolder(@NonNull View itemView) {
            super(itemView);
            mCheckBox = itemView.findViewById(R.id.group_user_check_box);
            mImageAvatar = itemView.findViewById(R.id.group_user_avatar);
            mTextName = itemView.findViewById(R.id.group_user_name);
            mTextHint = itemView.findViewById(R.id.group_user_hint);
        }

        public void layoutView(GroupMemberInfo userInfo) {
            if (userInfo == null || TextUtils.isEmpty(userInfo.userId)) {
                return;
            }
            itemView.setEnabled(!userInfo.isSelected);
            mCheckBox.setEnabled(!userInfo.isSelected);
            mCheckBox.setChecked(userInfo.isSelected);
            mCheckBox.setSelected(userInfo.isSelected);

            mTextName.setText((TextUtils.isEmpty(userInfo.userName)) ? userInfo.userId : userInfo.userName);
            mTextHint.setVisibility((userInfo.userId.equals(TUILogin.getLoginUser())) ? View.VISIBLE : View.GONE);
            ImageLoader.loadImage(mContext, mImageAvatar, userInfo.avatar, R.drawable.tuicalling_ic_avatar);
        }
    }
}