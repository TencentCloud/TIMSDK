package com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.constraintlayout.utils.widget.ImageFilterView;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.state.UserState;

import java.util.List;

public class AttendeesDisplayAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    private       List<UserState.UserInfo> mScheduledRoomDataList;
    private final Context                  mContext;
    private final LayoutInflater           mLayoutInflater;

    public AttendeesDisplayAdapter(Context context, List<UserState.UserInfo> list) {
        this.mContext = context;
        this.mLayoutInflater = LayoutInflater.from(mContext);
        mScheduledRoomDataList = list;
    }


    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View contentView = mLayoutInflater.inflate(R.layout.tuiroomkit_schedule_attendees_item, parent, false);
        return new ViewHolderAttendee(contentView);
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        UserState.UserInfo user = mScheduledRoomDataList.get(position);
        if (holder instanceof ViewHolderAttendee) {
            ((ViewHolderAttendee) holder).bind(user);
        }
    }

    @Override
    public int getItemCount() {
        return mScheduledRoomDataList.size();
    }

    private class ViewHolderAttendee extends RecyclerView.ViewHolder {

        private ImageFilterView mImgAvatar;
        private TextView        mUserName;

        public ViewHolderAttendee(@NonNull View itemView) {
            super(itemView);
            initView(itemView);
        }

        private void initView(View itemView) {
            mImgAvatar = itemView.findViewById(R.id.img_attendee_avatar);
            mUserName = itemView.findViewById(R.id.tv_attendee_name);
        }

        public void bind(UserState.UserInfo user) {
            ImageLoader.loadImage(mContext, mImgAvatar, user.avatarUrl, R.drawable.tuiroomkit_ic_avatar);
            mUserName.setText(user.userName);
        }
    }
}
