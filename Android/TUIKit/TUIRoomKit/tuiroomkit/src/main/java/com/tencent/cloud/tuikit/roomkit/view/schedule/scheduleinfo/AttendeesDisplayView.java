package com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo;

import android.content.Context;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.state.UserState;

import java.util.List;
import java.util.Locale;

public class AttendeesDisplayView extends BottomSheetDialog {
    private final static String       FORMAT_SELECT_ATTENDEE = "%s (%d)";
    private              Context      mContext;
    private              RecyclerView mRvAttendeesView;
    private              TextView     mTvSelectedAttendeeTitle;

    public AttendeesDisplayView(@NonNull Context context) {
        super(context, R.style.TUIRoomDialogFragmentTheme);
        setContentView(R.layout.tuiroomkit_view_attendees_display);
        mContext = context;
        initView();
    }

    public void setAttendees(List<UserState.UserInfo> attendees) {
        String text = String.format(Locale.getDefault(), FORMAT_SELECT_ATTENDEE, mContext.getString(R.string.tuiroomkit_selected_text), attendees.size());
        mTvSelectedAttendeeTitle.setText(text);
        mRvAttendeesView.setAdapter(new AttendeesDisplayAdapter(mContext, attendees));
    }

    private void initView() {
        mTvSelectedAttendeeTitle = findViewById(R.id.tv_selected_attendee_count_title);
        mRvAttendeesView = findViewById(R.id.rv_attendee_list);
        mRvAttendeesView.setLayoutManager(new LinearLayoutManager(mContext));
    }
}
