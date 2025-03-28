package com.tencent.cloud.tuikit.roomkit.view.main.transferownercontrolpanel;

import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.VideoStreamType.SCREEN_STREAM;

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
import com.tencent.cloud.tuikit.roomkit.state.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.common.utils.ImageLoader;

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
        holder.bind(user);
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

        private void bind(UserEntity user) {
            if (hideItemIfNeeded(user)) {
                return;
            }
            int visibility = TextUtils.equals(user.getUserId(), mSelectedUserId) ? View.VISIBLE : View.GONE;
            imageSelected.setVisibility(visibility);
            ImageLoader.loadImage(mContext, imageHead, user.getAvatarUrl(), R.drawable.tuiroomkit_head);
            String nameCard = TextUtils.isEmpty(user.getNameCard()) ? user.getUserName() : user.getNameCard();
            String userName = TextUtils.isEmpty(nameCard) ? user.getUserId() : nameCard;
            textUserName.setText(userName);
            rootView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mSelectedUserId = user.getUserId();
                    notifyDataSetChanged();
                }
            });
        }

        private boolean hideItemIfNeeded(UserEntity user) {
            if (user.getVideoStreamType() == SCREEN_STREAM || TextUtils.equals(user.getUserId(),
                    ConferenceController.sharedInstance().getConferenceState().userModel.userId)) {
                rootView.setLayoutParams(new RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0));
                return true;
            }
            if (rootView.getHeight() == 0) {
                rootView.setLayoutParams(new RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                        (int) mContext.getResources()
                                .getDimension(R.dimen.tuiroomkit_transfer_master_list_item_height)));
            }
            return false;
        }
    }
}
