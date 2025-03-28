package com.tencent.cloud.tuikit.roomkit.view.main.contacts.view;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.main.contacts.adapter.SelectedDialogAdapter;
import com.tencent.cloud.tuikit.roomkit.view.main.contacts.store.ContactsStateHolder;
import com.tencent.cloud.tuikit.roomkit.view.main.contacts.store.Participants;

import java.util.List;
import java.util.Locale;

public class SelectedParticipantsDialog extends BottomSheetDialog {
    private Context               mContext;
    private RecyclerView          mRecyclerSelectedParticipants;
    private TextView              mTvSelectedAttendeeTitle;
    private SelectedDialogAdapter mAdapter;
    private ImageView             mImgDismissIcon;
    private ContactsStateHolder   mStateHolder;

    public SelectedParticipantsDialog(@NonNull Context context) {
        super(context, R.style.TUIRoomDialogFragmentTheme);
        setContentView(R.layout.tuiroomkit_dialog_selected_panel);
        mContext = context;
        initView();
    }

    private void initView() {
        mImgDismissIcon = findViewById(R.id.img_arrow_down);
        mImgDismissIcon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });
        mTvSelectedAttendeeTitle = findViewById(R.id.tv_selected_participant_count_title);
        mRecyclerSelectedParticipants = findViewById(R.id.rv_attendee_list);
        mRecyclerSelectedParticipants.setLayoutManager(new LinearLayoutManager(mContext));
    }

    public void setAttendees(List<ConferenceDefine.User> participants) {
        String text = String.format(Locale.getDefault(), getContext().getString(R.string.tuiroomkit_format_select_participant), mContext.getString(R.string.tuiroomkit_selected_text), participants.size());
        mTvSelectedAttendeeTitle.setText(text);
        mAdapter = new SelectedDialogAdapter(mContext, participants);
        mRecyclerSelectedParticipants.setAdapter(mAdapter);
        mAdapter.setParticipantDeletedCallback(new SelectedDialogAdapter.DeleteParticipantCallback() {
            @Override
            public void onParticipantDeleted(ConferenceDefine.User user) {
                mAdapter.removeParticipantItem(user);
                if (mStateHolder != null) {
                    Participants participant = new Participants();
                    participant.userInfo = user;
                    participant.isSelected = false;
                    mStateHolder.changeParticipant(participant);
                }
                String text = String.format(Locale.getDefault(), getContext().getString(R.string.tuiroomkit_format_select_participant), mContext.getString(R.string.tuiroomkit_selected_text), mAdapter.getDeletedParticipantsSize());
                mTvSelectedAttendeeTitle.setText(text);
            }
        });
    }

    public void setStateHolder(ContactsStateHolder stateHolder) {
        mStateHolder = stateHolder;
    }
}
