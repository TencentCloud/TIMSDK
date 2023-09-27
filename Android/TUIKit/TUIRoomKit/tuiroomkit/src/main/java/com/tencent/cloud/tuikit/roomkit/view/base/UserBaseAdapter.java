package com.tencent.cloud.tuikit.roomkit.view.base;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;

import java.util.ArrayList;
import java.util.List;

public abstract class UserBaseAdapter extends RecyclerView.Adapter<UserBaseAdapter.UserBaseViewHolder> {
    private Context          mContext;
    private List<UserEntity> mModelList;

    public UserBaseAdapter(Context context) {
        mContext = context;
        mModelList = new ArrayList<>();
    }

    public void setDataList(List<UserEntity> list) {
        if (list == null) {
            return;
        }
        this.mModelList = list;
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public UserBaseViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(getLayoutId(), parent, false);
        return createViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull UserBaseViewHolder holder, int position) {
        UserEntity userEntity = mModelList.get(position);
        holder.bind(mContext, userEntity);
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

        public abstract void bind(Context context, UserEntity userEntity);
    }
}
