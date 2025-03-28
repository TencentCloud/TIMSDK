package com.tencent.cloud.tuikit.roomkit.view.main.contacts.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.constraintlayout.utils.widget.ImageFilterView;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.ImageLoader;

import java.util.ArrayList;
import java.util.List;

public class SelectedDialogAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    private final Context mContext;

    private List<ConferenceDefine.User> mSelectedParticipants;
    private DeleteParticipantCallback   mCallback;

    public interface DeleteParticipantCallback {
        void onParticipantDeleted(ConferenceDefine.User participant);
    }

    public SelectedDialogAdapter(Context context, List<ConferenceDefine.User> list) {
        this.mContext = context;
        mSelectedParticipants = new ArrayList<>(list);
    }

    public void setParticipantDeletedCallback(DeleteParticipantCallback callback) {
        mCallback = callback;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View contentView = LayoutInflater.from(mContext).inflate(R.layout.tuiroomkit_item_selected_participants, parent, false);
        return new ViewHolderAttendee(contentView);
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        ConferenceDefine.User user = mSelectedParticipants.get(position);
        if (holder instanceof ViewHolderAttendee) {
            ((ViewHolderAttendee) holder).bind(user);
        }
    }

    @Override
    public int getItemCount() {
        return mSelectedParticipants.size();
    }

    private class ViewHolderAttendee extends RecyclerView.ViewHolder {
        private ImageFilterView mImgAvatar;
        private TextView        mUserName;
        private FrameLayout     mFlDeleteParticipant;

        public ViewHolderAttendee(@NonNull View itemView) {
            super(itemView);
            initView(itemView);
        }

        private void initView(View itemView) {
            mFlDeleteParticipant = itemView.findViewById(R.id.fl_delete_participant);
            mImgAvatar = itemView.findViewById(R.id.img_participant_avatar);
            mUserName = itemView.findViewById(R.id.tv_participant_name);
        }

        public void bind(ConferenceDefine.User user) {
            ImageLoader.loadImage(mContext, mImgAvatar, user.avatarUrl, R.drawable.tuiroomkit_ic_avatar);
            mUserName.setText(user.name);
            mFlDeleteParticipant.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mCallback.onParticipantDeleted(user);
                }
            });
        }
    }

    public void removeParticipantItem(ConferenceDefine.User user) {
        if (mSelectedParticipants.contains(user)) {
            int index = mSelectedParticipants.indexOf(user);
            mSelectedParticipants.remove(user);
            notifyItemRemoved(index);
        }
    }

    public int getDeletedParticipantsSize() {
        return mSelectedParticipants.size();
    }
}
