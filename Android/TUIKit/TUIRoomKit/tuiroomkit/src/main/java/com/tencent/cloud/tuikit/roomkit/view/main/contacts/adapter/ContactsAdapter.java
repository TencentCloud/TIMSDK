package com.tencent.cloud.tuikit.roomkit.view.main.contacts.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.constraintlayout.utils.widget.ImageFilterView;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.view.main.contacts.store.ContactsStateHolder;
import com.tencent.cloud.tuikit.roomkit.view.main.contacts.store.Participants;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class ContactsAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    private Context             mContext;
    private List<Participants>  mParticipants = new ArrayList<>();
    private ContactsStateHolder mStateHolder;

    public ContactsAdapter(Context context) {
        mContext = context;
    }

    public void setAttendees(List<Participants> participants) {
        mParticipants = new ArrayList<>(participants);
        notifyDataSetChanged();
    }

    public void setStateHolder(ContactsStateHolder stateHolder) {
        mStateHolder = stateHolder;
    }

    public void updateItem(Participants item) {
        for (Participants participants : mParticipants) {
            if (TextUtils.equals(item.userInfo.id, participants.userInfo.id)) {
                participants.isSelected = item.isSelected;
                int index = mParticipants.indexOf(participants);
                notifyItemChanged(index);
                break;
            }
        }
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(mContext).inflate(R.layout.tuiroomkit_view_contacts_item, parent, false);
        return new ParticipantViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        Participants item = mParticipants.get(position);
        if (holder instanceof ParticipantViewHolder) {
            ((ParticipantViewHolder) holder).bind(item);
        }
    }

    @Override
    public int getItemCount() {
        return mParticipants.size();
    }

    private class ParticipantViewHolder extends RecyclerView.ViewHolder {
        private ImageFilterView  mImgAvatar;
        private TextView         mTvUserName;
        private FrameLayout      mFlSelectUserTag;
        private ConstraintLayout mItemLayout;

        public ParticipantViewHolder(@NonNull View itemView) {
            super(itemView);
            initView(itemView);
        }

        private void initView(View itemView) {
            mItemLayout = itemView.findViewById(R.id.cl_select_participant_item);
            mImgAvatar = itemView.findViewById(R.id.img_attendee_avatar);
            mTvUserName = itemView.findViewById(R.id.tv_attendee_name);
            mFlSelectUserTag = itemView.findViewById(R.id.cb_select_user_button);
        }

        public void bind(Participants item) {
            String userName = String.format(Locale.getDefault(), mContext.getString(R.string.tuiroomkit_participant_name_and_id), item.userInfo.name, item.userInfo.id);
            mTvUserName.setText(userName);
            ImageLoader.loadImage(mContext, mImgAvatar, item.userInfo.avatarUrl, R.drawable.tuiroomkit_ic_avatar);
            mFlSelectUserTag.setBackgroundResource(item.isSelected || item.isDisable ? R.drawable.tuiroomkit_bg_attendee_selected : R.drawable.tuiroomkit_bg_attendee_unselected);
            mItemLayout.setAlpha(item.isDisable ? (float) 0.5 : 1);
            mItemLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (item.isDisable) {
                        return;
                    }
                    item.isSelected = !item.isSelected;
                    mFlSelectUserTag.setBackgroundResource(item.isSelected ? R.drawable.tuiroomkit_bg_attendee_selected : R.drawable.tuiroomkit_bg_attendee_unselected);
                    if (mStateHolder != null) {
                        mStateHolder.changeParticipant(item);
                    }
                }
            });
        }
    }
}
