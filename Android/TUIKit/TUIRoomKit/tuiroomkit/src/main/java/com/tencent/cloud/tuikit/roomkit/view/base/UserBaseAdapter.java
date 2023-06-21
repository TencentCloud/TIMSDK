package com.tencent.cloud.tuikit.roomkit.view.base;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;

import java.util.ArrayList;
import java.util.List;

public abstract class UserBaseAdapter extends RecyclerView.Adapter<UserBaseAdapter.UserBaseViewHolder> {
    private Context         mContext;
    private List<UserModel> mModelList;

    public UserBaseAdapter(Context context) {
        mContext = context;
        mModelList = new ArrayList<>();
    }

    public void setDataList(List<UserModel> list) {
        if (list == null) {
            return;
        }
        this.mModelList = list;
        notifyDataSetChanged();
    }

    public void addItem(UserModel userModel) {
        if (userModel == null) {
            return;
        }
        mModelList.add(userModel);
        notifyItemInserted(mModelList.size());
    }

    public void removeItem(UserModel userModel) {
        if (userModel == null) {
            return;
        }
        int index = mModelList.indexOf(userModel);
        if (index == -1) {
            return;
        }
        mModelList.remove(userModel);
        notifyItemRemoved(index);
    }

    public void updateItem(UserModel userModel) {
        if (userModel == null) {
            return;
        }
        for (int i = 0; i < mModelList.size(); i++) {
            if (mModelList.get(i) != null
                    && mModelList.get(i).userId.equals(userModel.userId)) {
                mModelList.set(i, userModel);
                notifyItemChanged(i);
                return;
            }
        }
    }

    @NonNull
    @Override
    public UserBaseViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(getLayoutId(), parent, false);
        return createViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull UserBaseViewHolder holder, int position) {
        UserModel userModel = mModelList.get(position);
        if (userModel != null) {
            holder.bind(mContext, userModel);
        }
    }

    @Override
    public int getItemCount() {
        return mModelList == null ? 0 : mModelList.size();
    }

    protected abstract UserBaseViewHolder createViewHolder(View view);

    protected abstract int getLayoutId();

    public abstract static class UserBaseViewHolder extends RecyclerView.ViewHolder {

        public UserBaseViewHolder(@NonNull View itemView) {
            super(itemView);
        }

        public abstract void bind(Context context, UserModel userModel);
    }
}
