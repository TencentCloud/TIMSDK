package com.tencent.cloud.tuikit.roomkit.view.page.widget.TransferOwnerControlPanel;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.utils.ImageLoader;

import java.util.List;

import de.hdodenhof.circleimageview.CircleImageView;

public class TransferOwnerAdapter extends RecyclerView.Adapter<TransferOwnerAdapter.ViewHolder> {
    private String mSelectedUserId;

    private Context mContext;

    private List<UserEntity> mUserList;

    public TransferOwnerAdapter(Context context) {
        super();
        mContext = context;
    }

    public void setDataList(List<UserEntity> userList) {
        mUserList = userList;
        notifyDataSetChanged();
    }

    public String getSelectedUserId() {
        return mSelectedUserId;
    }

    @NonNull
    @Override
    public TransferOwnerAdapter.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(mContext).inflate(R.layout.tuiroomkit_item_specify_master, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull TransferOwnerAdapter.ViewHolder holder, int position) {
        UserEntity user = mUserList.get(position);
        int visibility = TextUtils.equals(user.getUserId(), mSelectedUserId) ? View.VISIBLE : View.GONE;
        holder.imageSelected.setVisibility(visibility);
        ImageLoader.loadImage(mContext, holder.imageHead, user.getAvatarUrl(), R.drawable.tuiroomkit_head);
        String userName = TextUtils.isEmpty(user.getUserName()) ? user.getUserId() : user.getUserName();
        holder.textUserName.setText(userName);
        holder.rootView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mSelectedUserId = user.getUserId();
                notifyDataSetChanged();
            }
        });
    }

    @Override
    public int getItemCount() {
        return mUserList.size();
    }

    class ViewHolder extends RecyclerView.ViewHolder {
        public View            rootView;
        public TextView        textUserName;
        public ImageView       imageSelected;
        public CircleImageView imageHead;

        public ViewHolder(View itemView) {
            super(itemView);
            initView(itemView);
        }

        private void initView(final View itemView) {
            rootView = itemView.findViewById(R.id.cl_item_root);
            imageHead = itemView.findViewById(R.id.img_head);
            textUserName = itemView.findViewById(R.id.tv_user_name);
            imageSelected = itemView.findViewById(R.id.img_selected);
        }
    }
}
