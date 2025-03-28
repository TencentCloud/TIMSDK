package com.tencent.cloud.tuikit.roomkit.view.main.raisehandcontrolpanel;

import static com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant.USER_NOT_FOUND;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.state.entity.TakeSeatRequestEntity;
import com.tencent.cloud.tuikit.roomkit.common.utils.ImageLoader;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import de.hdodenhof.circleimageview.CircleImageView;

public class RaiseHandApplicationListAdapter extends RecyclerView.Adapter<RaiseHandApplicationListAdapter.ViewHolder> {
    private List<TakeSeatRequestEntity> mRequestList;
    private Context                     mContext;

    public RaiseHandApplicationListAdapter(Context context) {
        mContext = context;
    }

    public void setDataList(List<TakeSeatRequestEntity> requestList) {
        mRequestList = requestList;
        notifyDataSetChanged();
    }

    public void updateRequestUserNameCard(String userId, String userName) {
        int position = USER_NOT_FOUND;
        for (int i = 0; i < mRequestList.size(); i++) {
            if (TextUtils.equals(userId, mRequestList.get(i).getUserId())) {
                mRequestList.get(i).setUserName(userName);
                position = i;
                break;
            }
        }
        if (position != USER_NOT_FOUND) {
            notifyItemChanged(position);
        }
    }

    @NonNull
    @Override
    public RaiseHandApplicationListAdapter.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(mContext)
                .inflate(R.layout.tuiroomkit_item_raise_hand_apply, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull RaiseHandApplicationListAdapter.ViewHolder holder, int position) {
        TakeSeatRequestEntity request = mRequestList.get(position);

        ImageLoader.loadImage(mContext, holder.ivHead, request.getAvatarUrl(), R.drawable.tuiroomkit_head);
        holder.tvUserName.setText(request.getUserName());
        holder.btnAgree.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Map<String, Object> params = new HashMap<>();
                params.put(ConferenceEventConstant.KEY_USER_ID, request.getUserId());
                ConferenceEventCenter.getInstance().notifyUIEvent(ConferenceEventCenter.RoomKitUIEvent.AGREE_TAKE_SEAT, params);
            }
        });
        holder.btnDisagree.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Map<String, Object> params = new HashMap<>();
                params.put(ConferenceEventConstant.KEY_USER_ID, request.getUserId());
                ConferenceEventCenter.getInstance().notifyUIEvent(ConferenceEventCenter.RoomKitUIEvent.DISAGREE_TAKE_SEAT, params);
            }
        });
    }

    @Override
    public int getItemCount() {
        return mRequestList.size();
    }

    class ViewHolder extends RecyclerView.ViewHolder {
        private Button          btnAgree;
        private Button          btnDisagree;
        private TextView        tvUserName;
        private CircleImageView ivHead;

        public ViewHolder(View itemView) {
            super(itemView);
            initView(itemView);
        }

        private void initView(final View itemView) {
            ivHead = itemView.findViewById(R.id.img_head);
            tvUserName = itemView.findViewById(R.id.tv_user_name);
            btnAgree = itemView.findViewById(R.id.btn_agree_apply);
            btnDisagree = itemView.findViewById(R.id.btn_disagree_apply);
        }
    }
}