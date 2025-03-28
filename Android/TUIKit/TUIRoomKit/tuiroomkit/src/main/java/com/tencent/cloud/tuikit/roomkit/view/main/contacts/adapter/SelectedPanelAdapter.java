package com.tencent.cloud.tuikit.roomkit.view.main.contacts.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.constraintlayout.utils.widget.ImageFilterView;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.view.main.contacts.store.Participants;

import java.util.ArrayList;
import java.util.List;

public class SelectedPanelAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    private Context                     mContext;
    private List<ConferenceDefine.User> mSelectedParticipants = new ArrayList<>();

    public SelectedPanelAdapter(Context context) {
        mContext = context;
    }

    public void setAttendees(List<ConferenceDefine.User> selectedParticipants) {
        mSelectedParticipants = selectedParticipants;
    }

    public List<ConferenceDefine.User> getSelectedParticipant() {
        return new ArrayList<>(mSelectedParticipants);
    }

    public void updateItem(Participants item) {
        if (item.isSelected && !mSelectedParticipants.contains(item.userInfo)) {
            mSelectedParticipants.add(item.userInfo);
            notifyItemInserted(mSelectedParticipants.size());
            return;
        }
        if (!item.isSelected && mSelectedParticipants.contains(item.userInfo)) {
            int position = mSelectedParticipants.indexOf(item.userInfo);
            mSelectedParticipants.remove(item.userInfo);
            notifyItemRemoved(position);
        }
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(mContext).inflate(R.layout.tuiroomkit_selected_participant_avatar, parent, false);
        return new ParticipantAvatarViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        ConferenceDefine.User item = mSelectedParticipants.get(position);
        if (holder instanceof ParticipantAvatarViewHolder) {
            ((ParticipantAvatarViewHolder) holder).bind(item);
        }
    }

    @Override
    public int getItemCount() {
        return mSelectedParticipants.size();
    }

    private class ParticipantAvatarViewHolder extends RecyclerView.ViewHolder {
        private ImageFilterView mParticipantAvatar;

        public ParticipantAvatarViewHolder(@NonNull View itemView) {
            super(itemView);
            mParticipantAvatar = itemView.findViewById(R.id.img_selected_participant_avatar);
        }

        public void bind(ConferenceDefine.User item) {
            ImageLoader.loadImage(mContext, mParticipantAvatar, item.avatarUrl, R.drawable.tuiroomkit_ic_avatar);
        }
    }
}
